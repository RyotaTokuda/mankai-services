export type PlanType = "free" | "plus" | "pro" | "pass_24h" | "premium";

export interface PlanInfo {
  name: string;
  monthlyReads: number;
}

export const PLAN_INFO: Record<PlanType, PlanInfo> = {
  free: { name: "Free", monthlyReads: 5 },
  plus: { name: "Plus", monthlyReads: 50 },
  pro: { name: "Pro", monthlyReads: -1 },
  pass_24h: { name: "24時間パス", monthlyReads: -1 },
  premium: { name: "Premium", monthlyReads: -1 },
};
