/**
 * Mankai Software 全アプリ共通のプラン定義
 *
 * 各アプリは appId でフィルタして自分のプランを取得する。
 * Stripe の Price ID は環境変数で管理し、ここには書かない。
 */

export type PlanId = "free" | "pro";

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
  pro: {
    id: "pro",
    name: "Pro",
    priceMonthly: 500, // 円（税抜）— 実装時に変更
  },
};
