// API 精度・速度テスト
// npx tsx src/lib/api-test.ts で実行
import * as fs from "fs";
import * as path from "path";

const API_URL = "https://parking-fee-calculator-brown.vercel.app/api/analyze";
const IMAGE_DIR = "/Users/ryotatokuda/Dropbox/My Mac (RyotanoMacBook-Pro.local)/Downloads/駐車代";

type Result = {
  file: string;
  timeMs: number;
  status: "ok" | "error";
  name?: string;
  zones?: number;
  slotsTotal?: number;
  maxPricesTotal?: number;
  notesTotal?: number;
  error?: string;
  summary?: string;
};

async function testImage(filePath: string): Promise<Result> {
  const file = path.basename(filePath);
  const buf = fs.readFileSync(filePath);
  const base64 = buf.toString("base64");
  const ext = path.extname(file).toLowerCase();
  const mimeType = ext === ".png" ? "image/png" : "image/jpeg";

  const start = Date.now();
  try {
    const res = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ imageBase64: base64, mimeType }),
      signal: AbortSignal.timeout(60000),
    });
    const timeMs = Date.now() - start;
    const data = await res.json();

    if (!res.ok || !data.rules) {
      return { file, timeMs, status: "error", error: data.error ?? `HTTP ${res.status}` };
    }

    const rules = data.rules;
    const zones = rules.zones?.length ?? 0;
    const slotsTotal = (rules.zones ?? []).reduce((s: number, z: any) => s + (z.slots?.length ?? 0), 0);
    const maxPricesTotal = (rules.zones ?? []).reduce((s: number, z: any) => s + (z.maxPrices?.length ?? 0), 0);
    const notesTotal = rules.notes?.length ?? 0;

    // 1行サマリ
    const slotSummaries = (rules.zones ?? []).flatMap((z: any) =>
      (z.slots ?? []).map((s: any) => `${s.startHour}-${s.endHour}h ¥${s.unitPrice}/${s.unitMinutes}分`)
    );
    const mpSummaries = (rules.zones ?? []).flatMap((z: any) =>
      (z.maxPrices ?? []).map((mp: any) => {
        const range = mp.type === "per_period" && mp.startHour != null ? `(${mp.startHour}-${mp.endHour}h)` : "";
        return `${mp.label ?? mp.type}${range}¥${mp.amount}`;
      })
    );
    const summary = `${slotSummaries.join(", ")} | ${mpSummaries.join(", ") || "最大なし"}`;

    return { file, timeMs, status: "ok", name: rules.name, zones, slotsTotal, maxPricesTotal, notesTotal, summary };
  } catch (err: any) {
    const timeMs = Date.now() - start;
    return { file, timeMs, status: "error", error: err.message };
  }
}

async function main() {
  const files = fs.readdirSync(IMAGE_DIR)
    .filter(f => /\.(jpe?g|png)$/i.test(f))
    .sort();

  console.log(`\n画像 ${files.length} 枚をテスト中...\n`);

  const results: Result[] = [];
  // 順次実行（無料枠 10回/分 → 7秒間隔でレート制限回避）
  for (let idx = 0; idx < files.length; idx++) {
    const file = files[idx];
    if (idx > 0) await new Promise(r => setTimeout(r, 7000));
    process.stdout.write(`  [${idx + 1}/${files.length}] ${file} ... `);
    const r = await testImage(path.join(IMAGE_DIR, file));
    results.push(r);
    if (r.status === "ok") {
      console.log(`✅ ${r.timeMs / 1000}s | ${r.name} | ${r.summary}`);
    } else {
      console.log(`❌ ${r.timeMs / 1000}s | ${r.error}`);
    }
  }

  // サマリ
  const ok = results.filter(r => r.status === "ok");
  const err = results.filter(r => r.status === "error");
  const times = ok.map(r => r.timeMs);
  const avg = times.length > 0 ? Math.round(times.reduce((a, b) => a + b, 0) / times.length) : 0;
  const min = times.length > 0 ? Math.min(...times) : 0;
  const max = times.length > 0 ? Math.max(...times) : 0;

  console.log(`\n═══ 結果サマリ ═══`);
  console.log(`成功: ${ok.length}/${results.length} (${err.length} 件エラー)`);
  console.log(`応答時間: 平均 ${avg / 1000}s / 最短 ${min / 1000}s / 最長 ${max / 1000}s`);

  if (err.length > 0) {
    console.log(`\nエラー一覧:`);
    for (const r of err) console.log(`  ❌ ${r.file}: ${r.error}`);
  }

  // 最大料金の有無チェック
  const noMaxPrice = ok.filter(r => r.maxPricesTotal === 0);
  if (noMaxPrice.length > 0) {
    console.log(`\n⚠️ 最大料金なし (${noMaxPrice.length}件):`);
    for (const r of noMaxPrice) console.log(`  ${r.file}: ${r.name}`);
  }
}

main();
