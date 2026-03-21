"use client";

import { useState } from "react";
import type { CarScenario, CostBreakdown } from "../lib/types";
import { formatYen } from "../lib/calc";

interface Props {
  scenario: CarScenario;
  costs: CostBreakdown;
}

function getPresets(carRate: number) {
  const presets = [
    { label: "高リセール（人気車）", rate: 55, example: "ジムニー, アルファード, ランクル" },
    { label: "標準", rate: 40, example: "一般的な国産車" },
    { label: "低リセール", rate: 25, example: "不人気車, 輸入車の一部" },
    { label: "大幅下落", rate: 15, example: "高年式・過走行の場合" },
  ];
  // この車種の目安がプリセットにない場合は先頭に追加
  if (!presets.some((p) => p.rate === carRate)) {
    presets.unshift({ label: "この車種の目安", rate: carRate, example: "" });
  }
  return presets;
}

export default function ResaleComparison({ scenario, costs }: Props) {
  const carRate = scenario.resaleRate || 40;
  const defaultRates = [carRate, ...[55, 40, 25].filter((r) => r !== carRate)].sort(
    (a, b) => b - a
  );
  const [rates, setRates] = useState(defaultRates);
  const [customRate, setCustomRate] = useState("");

  function addCustomRate() {
    const r = Number(customRate);
    if (r > 0 && r < 100 && !rates.includes(r)) {
      setRates((prev) => [...prev, r].sort((a, b) => b - a));
      setCustomRate("");
    }
  }

  const fiveYearMaintenance = costs.totalFiveYear;
  const price = scenario.vehiclePrice;

  const cases = rates.map((rate) => {
    const resaleValue = Math.round(price * (rate / 100));
    const realCost = fiveYearMaintenance - resaleValue;
    const realMonthly = Math.round(realCost / 60);
    return { rate, resaleValue, realCost, realMonthly };
  });

  const minCost = Math.min(...cases.map((c) => c.realCost));

  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5">
      <h3 className="text-sm font-bold mb-1">
        リセール率で変わる実質コスト（{scenario.name}）
      </h3>
      <p className="text-[11px] text-slate-400 mb-4">
        5年後に売却した場合、実際にかかるお金はいくら？リセール率で大きく変わります。
      </p>

      {/* リセール率プリセット */}
      <div className="flex flex-wrap gap-1.5 mb-4">
        {getPresets(carRate).map((p) => (
          <button
            key={p.rate}
            onClick={() => {
              if (!rates.includes(p.rate))
                setRates((prev) => [...prev, p.rate].sort((a, b) => b - a));
            }}
            className={`rounded-md px-2.5 py-1 text-[11px] border transition-colors ${
              rates.includes(p.rate)
                ? "border-blue-300 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-700"
                : "border-slate-200 dark:border-slate-600 text-slate-500 hover:border-blue-400"
            }`}
            title={p.example}
          >
            {p.label}（{p.rate}%）
          </button>
        ))}
        <div className="flex items-center gap-1">
          <input
            type="text"
            inputMode="numeric"
            value={customRate}
            onChange={(e) => setCustomRate(e.target.value.replace(/[^0-9]/g, ""))}
            placeholder="任意%"
            className="w-14 rounded-md border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 px-2 py-1 text-[11px] text-right focus:outline-none focus:ring-1 focus:ring-blue-400"
          />
          <button
            onClick={addCustomRate}
            className="text-[11px] text-blue-500 hover:text-blue-700"
          >
            追加
          </button>
        </div>
      </div>

      {/* 比較テーブル */}
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b-2 border-slate-200 dark:border-slate-600 text-[11px] text-slate-400">
              <th className="text-left py-2 pr-2">リセール率</th>
              <th className="text-right py-2 px-2">5年後の売却価格</th>
              <th className="text-right py-2 px-2">5年間の維持費総額</th>
              <th className="text-right py-2 px-2">実質コスト</th>
              <th className="text-right py-2 pl-2">月あたり実質</th>
            </tr>
          </thead>
          <tbody>
            {cases.map((c) => (
              <tr
                key={c.rate}
                className={`border-b border-slate-100 dark:border-slate-700 ${
                  c.realCost === minCost
                    ? "bg-green-50/50 dark:bg-green-950/20"
                    : ""
                }`}
              >
                <td className="py-2.5 pr-2 font-medium">{c.rate}%</td>
                <td className="text-right py-2.5 px-2 tabular-nums text-slate-500">
                  {formatYen(c.resaleValue)}円
                </td>
                <td className="text-right py-2.5 px-2 tabular-nums text-slate-500">
                  {formatYen(fiveYearMaintenance)}円
                </td>
                <td
                  className={`text-right py-2.5 px-2 tabular-nums font-bold ${
                    c.realCost === minCost
                      ? "text-green-600 dark:text-green-400"
                      : ""
                  }`}
                >
                  {formatYen(c.realCost)}円
                </td>
                <td className="text-right py-2.5 pl-2 tabular-nums">
                  {formatYen(c.realMonthly)}円/月
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* 差額サマリー */}
      {cases.length >= 2 && (
        <div className="mt-3 rounded-lg bg-amber-50/70 dark:bg-amber-950/30 border border-amber-100 dark:border-amber-900 px-3 py-2.5 text-center">
          <span className="text-xs text-slate-500">
            リセール率が{cases[0].rate}%と{cases[cases.length - 1].rate}%では、
            5年間の実質コストに
          </span>
          <span className="text-base font-bold text-amber-600 dark:text-amber-400 mx-1 tabular-nums">
            {formatYen(
              Math.abs(cases[cases.length - 1].realCost - cases[0].realCost)
            )}
            円
          </span>
          <span className="text-xs text-slate-500">の差</span>
        </div>
      )}

      <p className="text-[10px] text-slate-400 mt-3">
        ※ 実質コスト = 5年間の維持費総額 - 5年後の売却想定価格。車両購入費は維持費総額に含まれています（ローン返済として計上）。
      </p>
    </div>
  );
}
