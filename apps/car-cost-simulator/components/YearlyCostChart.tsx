"use client";

import type { CostBreakdown } from "../lib/types";
import { formatYen } from "../lib/calc";

interface CarResult {
  name: string;
  costs: CostBreakdown;
}

interface Props {
  results: CarResult[];
}

const COLORS = [
  "#3b82f6", // blue
  "#10b981", // emerald
  "#f59e0b", // amber
  "#ef4444", // red
  "#8b5cf6", // violet
];

export default function YearlyCostChart({ results }: Props) {
  if (results.length < 2) return null;

  const years = [1, 2, 3, 4, 5];

  // 各車種の年ごとの累積コスト
  const cumulativeData = results.map((r) =>
    years.map((y) => r.costs.totalAnnual * y)
  );

  const maxCost = Math.max(...cumulativeData.flat());

  // 年ごとの差額
  const yearlyDiffs = years.map((_, yi) => {
    const vals = cumulativeData.map((d) => d[yi]);
    return Math.max(...vals) - Math.min(...vals);
  });

  return (
    <div className="mt-6 rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5">
      <h3 className="text-base font-bold mb-4">年ごとの累積コスト比較</h3>

      {/* バーチャート */}
      <div className="space-y-3">
        {years.map((year, yi) => (
          <div key={year}>
            <div className="flex items-center justify-between mb-1">
              <span className="text-xs font-medium text-slate-500 w-12 shrink-0">
                {year}年目
              </span>
              <span className="text-[11px] text-slate-400">
                差額: {formatYen(yearlyDiffs[yi])}円
              </span>
            </div>
            <div className="space-y-1">
              {results.map((r, ri) => {
                const val = cumulativeData[ri][yi];
                const pct = maxCost > 0 ? (val / maxCost) * 100 : 0;
                const isMin =
                  val ===
                  Math.min(...cumulativeData.map((d) => d[yi]));
                return (
                  <div key={r.name} className="flex items-center gap-2">
                    <span className="text-[11px] text-slate-500 w-24 truncate shrink-0 text-right">
                      {r.name}
                    </span>
                    <div className="flex-1 h-5 bg-slate-100 dark:bg-slate-700 rounded-full overflow-hidden">
                      <div
                        className="h-full rounded-full transition-all duration-500"
                        style={{
                          width: `${Math.max(pct, 2)}%`,
                          backgroundColor: COLORS[ri % COLORS.length],
                          opacity: isMin ? 1 : 0.7,
                        }}
                      />
                    </div>
                    <span
                      className={`text-xs tabular-nums shrink-0 w-24 text-right font-medium ${
                        isMin
                          ? "text-green-600 dark:text-green-400"
                          : "text-slate-600 dark:text-slate-300"
                      }`}
                    >
                      {formatYen(val)}円
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* 凡例 */}
      <div className="flex flex-wrap gap-3 mt-4 pt-3 border-t border-slate-100 dark:border-slate-700">
        {results.map((r, ri) => (
          <div key={r.name} className="flex items-center gap-1.5">
            <span
              className="inline-block w-3 h-3 rounded-sm"
              style={{ backgroundColor: COLORS[ri % COLORS.length] }}
            />
            <span className="text-xs text-slate-500">{r.name}</span>
          </div>
        ))}
      </div>

      {/* 5年目の差額サマリー */}
      <div className="mt-3 rounded-lg bg-amber-50/70 dark:bg-amber-950/30 border border-amber-100 dark:border-amber-900 px-3 py-2.5 text-center">
        <span className="text-xs text-slate-500">5年間で</span>
        <span className="text-base font-bold text-amber-600 dark:text-amber-400 mx-1.5 tabular-nums">
          {formatYen(yearlyDiffs[4])}円
        </span>
        <span className="text-xs text-slate-500">の差がつきます</span>
      </div>
    </div>
  );
}
