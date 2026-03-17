import type { SupabaseClient } from "@supabase/supabase-js";

export type PlanStatus = "free" | "pro";

/**
 * ユーザーのサブスクリプション状態を Supabase から取得する
 *
 * Server Component・API Route のどちらからも呼べるよう、
 * Supabase クライアントを引数で受け取る設計にしている。
 *
 * 例（Server Component）:
 *   const supabase = await createClient();
 *   const plan = await getPlanStatus(supabase, user.id);
 */
export async function getPlanStatus(
  supabase: SupabaseClient,
  userId: string
): Promise<PlanStatus> {
  const { data } = await supabase
    .from("subscriptions")
    .select("status")
    .eq("user_id", userId)
    .eq("status", "active")
    .maybeSingle();

  return data ? "pro" : "free";
}

/**
 * 有料プランかどうかを判定する（getPlanStatus の便利ラッパー）
 */
export async function isPro(
  supabase: SupabaseClient,
  userId: string
): Promise<boolean> {
  return (await getPlanStatus(supabase, userId)) === "pro";
}
