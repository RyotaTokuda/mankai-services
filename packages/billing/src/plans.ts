/**
 * Mankai Software 全アプリ共通のプラン定義
 *
 * プラットフォームごとの Product ID は環境変数で管理し、ここには書かない。
 * - Web:     Lemon Squeezy Variant ID（NEXT_PUBLIC_LS_PRO_VARIANT_ID）
 * - Web:     Stripe Price ID（NEXT_PUBLIC_STRIPE_*_PRICE_ID）
 * - iOS:     App Store Product ID（環境変数 or アプリ内定数）
 * - Android: Google Play Product ID（環境変数 or アプリ内定数）
 */

export type PlanId = "free" | "plus" | "pro";

/** 購入元プラットフォーム。subscriptions テーブルに記録する */
export type BillingPlatform = "lemon" | "stripe" | "apple" | "google";

export interface Plan {
  id: PlanId;
  name: string;
  priceMonthly: number | null; // null = 無料
}

export const PLANS: Record<PlanId, Plan> = {
  free: {
    id: "free",
    name: "無料",
    priceMonthly: null,
  },
  plus: {
    id: "plus",
    name: "Plus",
    priceMonthly: 580,
  },
  pro: {
    id: "pro",
    name: "Pro",
    priceMonthly: 1280,
  },
};
