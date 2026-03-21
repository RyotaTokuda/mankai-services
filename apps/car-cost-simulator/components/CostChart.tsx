"use client";

import type { CostBreakdown } from "../lib/types";
import { formatYen } from "../lib/calc";

interface Props {
  costs: CostBreakdown;
}

const ITEMS: { key: keyof CostBreakdown; label: string; color: string }[] = [
  { key: "loanMonthly", label: "ローン", color: "#3b82f6" },
  { key: "parkingAnnual", label: "駐車場", color: "#8b5cf6" },
  { key: "insuranceAnnual", label: "保険", color: "#ec4899" },
  { key: "autoTax", label: "自動車税", color: "#f59e0b" },
  { key: "inspectionAnnual", label: "車検", color: "#10b981" },
  { key: "fuelAnnual", label: "燃料", color: "#ef4444" },
  { key: "tireAnnual", label: "タイヤ", color: "#6366f1" },
  { key: "maintenanceAnnual", label: "整備", color: "#14b8a6" },
];

function getAnnualValue(
  key: keyof CostBreakdown,
  costs: CostBreakdown
): number {
  if (key === "loanMonthly") return costs.loanMonthly * 12;
  return costs[key] as number;
}

export default function CostChart({ costs }: Props) {
  const data = ITEMS.map((item) => ({
    ...item,
    value: getAnnualValue(item.key, costs),
  })).filter((d) => d.value > 0);

  const total = data.reduce((sum, d) => sum + d.value, 0);
  if (total === 0) return null;

  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5 space-y-3">
      <div className="text-sm font-semibold text-slate-700 dark:text-slate-300">
        年間コスト内訳
      </div>

      {/* バー */}
      <div className="flex h-10 w-full overflow-hidden rounded-xl shadow-inner bg-slate-100 dark:bg-slate-700">
        {data.map((d) => {
          const pct = (d.value / total) * 100;
          return (
            <div
              key={d.key}
              style={{
                width: `${pct}%`,
                backgroundColor: d.color,
              }}
              className="h-full min-w-[3px] transition-all duration-300"
              title={`${d.label}: ${formatYen(d.value)}円/年 (${Math.round(pct)}%)`}
            />
          );
        })}
      </div>

      {/* 凡例 */}
      <div className="grid grid-cols-2 gap-x-4 gap-y-1.5 text-xs">
        {data.map((d) => {
          const pct = Math.round((d.value / total) * 100);
          return (
            <div key={d.key} className="flex items-center gap-2">
              <span
                className="inline-block h-3 w-3 rounded-sm shrink-0"
                style={{ backgroundColor: d.color }}
              />
              <span className="text-slate-500 dark:text-slate-400 truncate flex-1">
                {d.label}
              </span>
              <span className="tabular-nums font-medium text-slate-600 dark:text-slate-300 shrink-0">
                {formatYen(d.value)}円
              </span>
              <span className="text-slate-400 tabular-nums shrink-0">
                {pct}%
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
