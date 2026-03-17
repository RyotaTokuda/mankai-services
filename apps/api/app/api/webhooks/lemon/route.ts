import { NextResponse } from "next/server";
import { verifyWebhookSignature, processLemonEvent } from "@mankai/billing/lemon-webhook";
import type { LemonWebhookEvent } from "@mankai/billing/lemon-types";

/**
 * Lemon Squeezy Webhook エンドポイント
 * POST /api/webhooks/lemon
 *
 * セキュリティ対策:
 * 1. HMAC-SHA256 署名検証（timingSafeEqual）
 * 2. raw body を先に読む（署名検証後に JSON パース）
 * 3. 冪等性（packages/billing/webhook.ts で処理済みイベントをスキップ）
 * 4. エラー時のレスポンスコードを適切に分ける
 *    - 400: 署名不正・不正リクエスト → LS はリトライしない
 *    - 500: 処理失敗（DB エラー等） → LS はリトライする
 * 5. ログにペイロードを出力しない（顧客情報を含む可能性）
 */
export async function POST(request: Request) {
  // ── 1. raw body を読む（署名検証に必要） ─────────────────────────────
  // request.json() を先に呼ぶと body が消費されて署名検証できなくなる
  const rawBody = await request.text();

  // ── 2. 環境変数チェック ────────────────────────────────────────────────
  const secret = process.env.LEMON_SQUEEZY_WEBHOOK_SECRET;
  if (!secret) {
    // 設定ミスは 500 でリトライさせる（503 でも可）
    console.error("[lemon-webhook] LEMON_SQUEEZY_WEBHOOK_SECRET が未設定");
    return NextResponse.json({ error: "Configuration error" }, { status: 500 });
  }

  // ── 3. 署名検証 ────────────────────────────────────────────────────────
  const signature = request.headers.get("x-signature") ?? "";
  if (!verifyWebhookSignature(rawBody, signature, secret)) {
    // 400 → Lemon Squeezy はリトライしない（故意の改ざんか設定ミス）
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 });
  }

  // ── 4. JSON パース ─────────────────────────────────────────────────────
  let event: LemonWebhookEvent;
  try {
    event = JSON.parse(rawBody) as LemonWebhookEvent;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  // ── 5. イベント処理 ────────────────────────────────────────────────────
  try {
    await processLemonEvent(event);
    return NextResponse.json({ ok: true });
  } catch (err) {
    // エラーの詳細は外部に返さない（ログにのみ記録）
    console.error(
      "[lemon-webhook] 処理失敗:",
      err instanceof Error ? err.message : "unknown error"
    );
    // 500 → Lemon Squeezy がリトライする
    return NextResponse.json({ error: "Processing failed" }, { status: 500 });
  }
}

// GET は受け付けない（探索的アクセスへの対策）
export async function GET() {
  return NextResponse.json({ error: "Method not allowed" }, { status: 405 });
}

// Node.js runtime を使用（crypto モジュールが必要）
export const runtime = "nodejs";
