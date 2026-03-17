import { createHmac, timingSafeEqual } from "crypto";
import { createAdminClient } from "@mankai/auth/admin";
import type { LemonWebhookEvent, LemonSubscriptionStatus } from "./types";

/**
 * Lemon Squeezy Webhook 署名を検証する
 *
 * セキュリティ:
 * - timingSafeEqual を使用してタイミング攻撃を防止する
 * - 署名が不正な場合は false を返し、呼び出し側が 400 を返すこと
 *   （500 にすると LS が何度もリトライする）
 */
export function verifyWebhookSignature(
  rawBody: string,
  signature: string,
  secret: string
): boolean {
  if (!signature || !secret) return false;

  const hmac = createHmac("sha256", secret);
  const digest = hmac.update(rawBody).digest("hex");

  try {
    // Buffer の長さが異なると timingSafeEqual が throw するため try/catch
    return timingSafeEqual(
      Buffer.from(signature, "hex"),
      Buffer.from(digest, "hex")
    );
  } catch {
    return false;
  }
}

/**
 * Lemon Squeezy Webhook イベントを処理する
 *
 * 冪等性:
 * - webhook_events テーブルにイベント ID を記録し、重複処理を防ぐ
 * - Lemon Squeezy は同一イベントを複数回送信することがある
 */
export async function processLemonEvent(event: LemonWebhookEvent): Promise<void> {
  const supabase = createAdminClient();
  const eventName = event.meta.event_name;
  const userId = event.meta.custom_data?.user_id;

  // custom_data に user_id がない場合は処理しない
  // （チェックアウト外からの購入など）
  if (!userId) {
    console.warn(`[lemon-webhook] user_id not found in custom_data for ${eventName}`);
    return;
  }

  // ── 冪等性チェック ──────────────────────────────────────────────────────
  // Lemon Squeezy の event_id はドキュメント上未保証のため、
  // subscription ID + event name の組み合わせをキーとする
  const idempotencyKey = `${event.data.id}:${eventName}`;

  const { data: existing } = await supabase
    .from("webhook_events")
    .select("id")
    .eq("id", idempotencyKey)
    .single();

  if (existing) {
    // 既に処理済み → 冪等に成功を返す
    return;
  }

  // 処理済みとして記録（先に書くことで並行リクエストによる二重処理を防ぐ）
  await supabase.from("webhook_events").insert({ id: idempotencyKey });

  // ── イベント別処理 ──────────────────────────────────────────────────────
  const attrs = event.data.attributes;

  switch (eventName) {
    case "subscription_created":
    case "subscription_updated":
    case "subscription_resumed":
    case "subscription_unpaused":
    case "subscription_payment_success":
    case "subscription_payment_recovered":
      await upsertSubscription(supabase, userId, event.data.id, attrs.status, attrs);
      break;

    case "subscription_cancelled":
    case "subscription_paused":
    case "subscription_expired":
    case "subscription_payment_failed":
      await upsertSubscription(supabase, userId, event.data.id, attrs.status, attrs);
      break;

    default:
      // 未知のイベントはスキップ（ログのみ）
      break;
  }
}

async function upsertSubscription(
  supabase: ReturnType<typeof createAdminClient>,
  userId: string,
  lemonSubscriptionId: string,
  status: LemonSubscriptionStatus,
  attrs: LemonWebhookEvent["data"]["attributes"]
): Promise<void> {
  const { error } = await supabase.from("subscriptions").upsert(
    {
      user_id: userId,
      lemon_subscription_id: lemonSubscriptionId,
      lemon_customer_id: String(attrs.customer_id),
      lemon_variant_id: String(attrs.variant_id),
      status,
      renews_at: attrs.renews_at ?? null,
      ends_at: attrs.ends_at ?? null,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "lemon_subscription_id" }
  );

  if (error) {
    throw new Error(`Supabase upsert failed: ${error.message}`);
  }
}
