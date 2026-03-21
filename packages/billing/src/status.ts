import type { SupabaseClient } from "@supabase/supabase-js";
import type { BillingPlatform, PlanId } from "./plans";

export type PlanStatus = PlanId;

/**
 * platform_product_id（Stripe Price ID 等）からプランを判定するマッピング。
 * アプリごとに異なるマッピングを渡せるよう、オプション引数で受け取る。
 */
export interface PlanResolverOptions {
  /** platform_product_id → PlanId のマッピング。マッチしなければ "pro"（後方互換） */
  productIdToPlan?: Record<string, PlanId>;
}

/**
 * ユーザーのサブスクリプション状態を Supabase から取得する
 *
 * プラットフォーム横断:
 * - Lemon Squeezy / Stripe / App Store / Google Play のどこで購入しても、
 *   subscriptions テーブルに "active" な行があれば有料プランと判定する。
 * - productIdToPlan を渡すと platform_product_id から Plus / Pro を判別できる。
 *   渡さない場合はアクティブなサブスクリプションがあれば "pro" を返す（後方互換）。
 *
 * Server Component・API Route のどちらからも呼べるよう、
 * Supabase クライアントを引数で受け取る設計にしている。
 */
export async function getPlanStatus(
  supabase: SupabaseClient,
  userId: string,
  options?: PlanResolverOptions,
): Promise<PlanStatus> {
  const { data } = await supabase
    .from("subscriptions")
    .select("status, platform_product_id")
    .eq("user_id", userId)
    .eq("status", "active")
    .maybeSingle();

  if (!data) return "free";

  // productIdToPlan が提供されている場合、platform_product_id で判定
  if (options?.productIdToPlan && data.platform_product_id) {
    return options.productIdToPlan[data.platform_product_id] ?? "pro";
  }

  // マッピングなし → 後方互換（アクティブ = pro）
  return "pro";
}

/**
 * 有料プランかどうかを判定する（getPlanStatus の便利ラッパー）
 */
export async function isPro(
  supabase: SupabaseClient,
  userId: string,
  options?: PlanResolverOptions,
): Promise<boolean> {
  return (await getPlanStatus(supabase, userId, options)) === "pro";
}

/**
 * Plus 以上かどうかを判定する
 */
export async function isPlusOrAbove(
  supabase: SupabaseClient,
  userId: string,
  options?: PlanResolverOptions,
): Promise<boolean> {
  const plan = await getPlanStatus(supabase, userId, options);
  return plan === "plus" || plan === "pro";
}

/**
 * ユーザーの購入プラットフォームを取得する
 *
 * 用途: 課金管理画面で「App Store で管理」「Web で管理」など
 *       適切な導線を出し分けるため。
 */
export async function getSubscriptionPlatform(
  supabase: SupabaseClient,
  userId: string,
): Promise<BillingPlatform | null> {
  const { data } = await supabase
    .from("subscriptions")
    .select("platform")
    .eq("user_id", userId)
    .eq("status", "active")
    .maybeSingle();

  return data?.platform ?? null;
}
