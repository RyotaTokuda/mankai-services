import { NextRequest, NextResponse } from "next/server";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { ParkingRules } from "@mankai/parking-shared";

// 安全設定値（CLAUDE.md: 課金抑制ルール）
const MAX_IMAGE_BYTES = 10 * 1024 * 1024; // 10MB
const API_TIMEOUT_MS = 30_000;            // 30秒
const MAX_RETRIES = 2;                    // 503/429 時のリトライ回数
const RETRY_DELAY_MS = 2_000;             // リトライ間隔

const PROMPT = `あなたは駐車場の料金看板を解析するエキスパートです。
看板の画像を受け取り、料金ルールを JSON 形式で返してください。

返す JSON は以下の型に厳密に従ってください:

{
  "name": string,           // 駐車場名（看板に記載がなければ「駐車場」）
  "zones": [                // 駐車枠の種別ごとの料金（種別が1種類なら要素1つ）
    {
      "name": string,       // 例: "全車種" / "普通車" / "軽自動車" / "バイク"
      "slots": [
        {
          "startHour": number,  // 0-23 の整数
          "endHour": number,    // 1-24 の整数 (24 = 翌0時)
          "unitMinutes": number,
          "unitPrice": number
        }
      ],
      "maxPrices": [        // 最大料金のリスト（なければ空配列 []）
        {
          "amount": number,
          "type": "per_day" | "per_24h_once" | "per_24h_repeat" | "per_period",
          "label": string,  // 例: "昼間最大" / "夜間最大" / "24時間最大" / "最大料金"
          "startHour": number | undefined,  // per_period のみ: 対象開始時（0-23）
          "endHour": number | undefined     // per_period のみ: 対象終了時（1-24）
        }
      ]
    }
  ],
  "notes": [
    {
      "priority": "high" | "medium" | "low",
      "category": "max_price" | "vehicle" | "payment" | "reentry" | "schedule" | "discount",
      "text": string
    }
  ]
}

━━ zones の読み方 ━━
・駐車枠の種別が1種類（区別なし）→ zones に要素1つ、name は "全車種"
・普通車と軽自動車で料金が異なる → zones に要素2つ（name: "普通車", "軽自動車"）
・バイクも含む → zones に "バイク" を追加

━━ slots の読み方 ━━
・「8:00〜22:00 30分200円」→ { startHour:8, endHour:22, unitMinutes:30, unitPrice:200 }
・「22:00〜8:00 60分100円」→ { startHour:22, endHour:8, unitMinutes:60, unitPrice:100 }（日跨ぎはendHour<startHourで表現）
・「全時間帯 30分200円」→ { startHour:0, endHour:24, unitMinutes:30, unitPrice:200 }
・「駐車後1時間無料、以降30分200円」→ 無料部分はスロット不要、有料部分のみ記載し notes に「最初の1時間無料」を記載

━━ maxPrices の判断ルール（最重要）━━
【含める条件】看板に「最大〇〇円」「上限〇〇円」「〇〇円以内」など、明示的な上限金額の記載がある場合のみ。
【含めない条件】以下のケースでは maxPrices を空配列 [] にする:
  × 「最大」という文字がない場合
  × 時間制料金だけが書いてある場合（例:「30分200円」のみ）
  × 読み取れない・判断できない場合

type の判断基準:
- "per_period": 「昼間最大〇〇円」「夜間最大〇〇円」など特定時間帯に限定した上限 → startHour/endHour を必ず設定
- "per_day":    「最大料金 ○○円（当日限り）」「1日最大」「0時リセット」など
- "per_24h_once": 「24時間最大 ○○円」「入庫から24時間以内」など（繰り返し記載なし）
- "per_24h_repeat": 「24時間ごと最大」「以降24時間ごと」など繰り返しを明示

━━ 入力例と期待する出力 ━━

例1（種別なし・最大料金なし）:
看板:「8:00-22:00 20分100円 / 22:00-8:00 60分100円」
→ {
  "zones": [{"name":"全車種","slots":[{"startHour":8,"endHour":22,"unitMinutes":20,"unitPrice":100},{"startHour":22,"endHour":8,"unitMinutes":60,"unitPrice":100}],"maxPrices":[]}]
}

例2（昼間・夜間の最大料金あり）:
看板:「8:00-22:00 30分200円 昼間最大1500円 / 22:00-8:00 60分100円 夜間最大500円」
→ {
  "zones": [{"name":"全車種","slots":[{"startHour":8,"endHour":22,"unitMinutes":30,"unitPrice":200},{"startHour":22,"endHour":8,"unitMinutes":60,"unitPrice":100}],"maxPrices":[{"amount":1500,"type":"per_period","label":"昼間最大","startHour":8,"endHour":22},{"amount":500,"type":"per_period","label":"夜間最大","startHour":22,"endHour":8}]}]
}

例3（24時間最大あり・全日）:
看板:「24時間営業 30分300円 / 24時間最大2000円」
→ {
  "zones": [{"name":"全車種","slots":[{"startHour":0,"endHour":24,"unitMinutes":30,"unitPrice":300}],"maxPrices":[{"amount":2000,"type":"per_24h_once","label":"24時間最大"}]}]
}

例4（普通車・軽自動車で料金が異なる）:
看板:「普通車 30分200円 最大1500円 / 軽自動車 30分150円 最大1000円」
→ {
  "zones": [
    {"name":"普通車","slots":[{"startHour":0,"endHour":24,"unitMinutes":30,"unitPrice":200}],"maxPrices":[{"amount":1500,"type":"per_day","label":"最大料金"}]},
    {"name":"軽自動車","slots":[{"startHour":0,"endHour":24,"unitMinutes":30,"unitPrice":150}],"maxPrices":[{"amount":1000,"type":"per_day","label":"最大料金"}]}
  ]
}

━━ 注意事項カテゴリ ━━
- "max_price": 最大料金の条件（0時リセット、繰り返しなど）
- "vehicle": 車両制限（高さ・幅・重量）
- "payment": 支払い方法（現金のみ等）
- "reentry": 再入庫ルール
- "schedule": 曜日・祝日の例外
- "discount": サービス割引

優先度:
- "high": 間違えると損をする情報（最大料金の条件、車両制限）
- "medium": 知っておくべき情報
- "low": 補足情報

━━ 厳守事項 ━━
- JSON のみを返す。説明文・マークダウン・コードブロックは一切不要
- 看板に明示的に記載されていない情報は絶対に含めない
- maxPrices に含めるのは「最大〇〇円」の明記がある場合のみ。不明な場合は空配列 []
- per_period を使う場合は startHour と endHour を必ず設定すること

━━ よくある間違い（絶対に避けること）━━
- slots と maxPrices を混同しないこと。slots は「○分○円」の時間制料金。maxPrices は「最大○円」の上限金額。両者は全く別の概念
- slots の unitPrice に最大料金の金額を入れないこと。例:「昼間最大900円」の900は maxPrices.amount であり、slots.unitPrice ではない
- maxPrices の amount にスロットの単価を入れないこと。例:「30分200円」の200は slots.unitPrice であり、maxPrices.amount ではない
- 1つのスロットの情報を2つに分割しないこと。例:「8:00〜20:00 30分200円」は1つの slot であり、2つに分けない
- 看板に数字が読み取れない場合は推測せず、読み取れた数字のみを使うこと

━━ 数字の読み取り精度（桁の誤読を防ぐ）━━
- 日本のコインパーキングの相場を参考に、読み取った数字が妥当か確認すること
- 時間制料金の典型的な相場:
  - 都市部: 100〜600円/30分、100〜300円/60分
  - 郊外: 50〜200円/30分、50〜100円/60分
  - 夜間: 100円/60分 が一般的
- 最大料金の典型的な相場: 500〜3000円（昼間）、300〜1000円（夜間）
- unitPrice が 10〜60円のような異常に安い値になった場合、桁を間違えている可能性が高い。看板を再確認すること
- unitMinutes は通常 10, 15, 20, 30, 40, 60, 90, 120 のいずれか。それ以外の値は誤読の可能性が高い
- 同じ駐車場で複数ゾーン（普通車・軽自動車など）がある場合、各ゾーンは独立した zones 要素にすること。1つの zone に異なる車種の料金を混ぜない`;

export async function POST(request: NextRequest) {
  // kill switch: OCR_ENABLED=false で全解析を無効化できる（緊急停止用）
  if (process.env.OCR_ENABLED === "false") {
    return NextResponse.json(
      { error: "現在サービスが混み合っています。しばらくしてから再度お試しください。" },
      { status: 503 }
    );
  }

  const apiKey = process.env.GOOGLE_GENERATIVE_AI_API_KEY;
  if (!apiKey) {
    return NextResponse.json(
      { error: "GOOGLE_GENERATIVE_AI_API_KEY が設定されていません" },
      { status: 500 }
    );
  }

  let body: { imageBase64: string; mimeType: string };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "リクエスト形式が不正です" }, { status: 400 });
  }

  const { imageBase64, mimeType } = body;
  if (!imageBase64 || !mimeType) {
    return NextResponse.json({ error: "画像データが不足しています" }, { status: 400 });
  }

  // 画像サイズ上限チェック（base64 → バイト数に換算）
  const estimatedBytes = Math.ceil((imageBase64.length * 3) / 4);
  if (estimatedBytes > MAX_IMAGE_BYTES) {
    return NextResponse.json(
      { error: `画像サイズが上限（10MB）を超えています（約${Math.round(estimatedBytes / 1024 / 1024)}MB）` },
      { status: 413 }
    );
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: "gemini-2.5-flash-lite",
    generationConfig: {
      temperature: 0,
      responseMimeType: "application/json",
    },
  });

  const contents = [
    { inlineData: { mimeType: mimeType || "image/jpeg", data: imageBase64 } },
    { text: PROMPT },
  ];

  // リトライ付きで Gemini を呼び出す（503/429 対策）
  for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    try {
      const result = await Promise.race([
        model.generateContent(contents),
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error("解析がタイムアウトしました（30秒）")), API_TIMEOUT_MS)
        ),
      ]);

      const raw = result.response.text().replace(/```json\s*/g, "").replace(/```\s*/g, "").trim();

      let rules: ParkingRules;
      try {
        rules = JSON.parse(raw) as ParkingRules;
      } catch {
        return NextResponse.json(
          { error: "看板の読み取りに失敗しました。別の角度から撮り直してみてください。", raw },
          { status: 500 }
        );
      }

      return NextResponse.json({ rules });
    } catch (error) {
      const message = error instanceof Error ? error.message : "";
      const isRetryable = message.includes("503") || message.includes("429") || message.includes("overloaded");

      if (isRetryable && attempt < MAX_RETRIES) {
        await new Promise((r) => setTimeout(r, RETRY_DELAY_MS * (attempt + 1)));
        continue;
      }

      return NextResponse.json(
        { error: isRetryable
            ? "現在サービスが混み合っています。しばらくしてから再度お試しください。"
            : (message || "解析中にエラーが発生しました") },
        { status: isRetryable ? 503 : 500 }
      );
    }
  }

  return NextResponse.json(
    { error: "解析に失敗しました。しばらくしてから再度お試しください。" },
    { status: 503 }
  );
}
