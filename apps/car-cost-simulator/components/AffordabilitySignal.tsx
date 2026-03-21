"use client";

import { useState } from "react";
import { formatYen } from "../lib/calc";

interface Props {
  totalAnnual: number;
}

import { AFFILIATE_LINKS } from "../data/affiliate-links";

function getSignal(ratio: number): {
  color: string;
  bg: string;
  label: string;
  message: string;
  tips: string[];
} {
  if (ratio <= 0.15) {
    return {
      color: "text-green-600 dark:text-green-400",
      bg: "bg-green-50 dark:bg-green-950/40 border-green-200 dark:border-green-800",
      label: "余裕あり",
      message: "年収の15%以下。家計への負担は小さいです。",
      tips: [],
    };
  }
  if (ratio <= 0.25) {
    return {
      color: "text-amber-600 dark:text-amber-400",
      bg: "bg-amber-50 dark:bg-amber-950/40 border-amber-200 dark:border-amber-800",
      label: "やや注意",
      message: "年収の15〜25%。生活費や貯蓄とのバランスを確認しましょう。",
      tips: [
        "頭金を増やしてローン返済額を減らす",
        "ローン年数を延ばして月々の負担を軽くする",
        "任意保険を一括見積りで見直す",
      ],
    };
  }
  return {
    color: "text-red-600 dark:text-red-400",
    bg: "bg-red-50 dark:bg-red-950/40 border-red-200 dark:border-red-800",
    label: "要検討",
    message: "年収の25%超。家計を圧迫する可能性があります。",
    tips: [
      "車両価格を下げる（1ランク下のグレードや中古車を検討）",
      "頭金を増やしてローン元本を減らす",
      "カーリースで月々定額にして維持費を管理しやすくする",
      "駐車場の安いエリアを探す",
      "年間走行距離を減らせないか検討する（燃料費削減）",
      "任意保険を一括見積りで見直す（年間数万円の差が出ることも）",
    ],
  };
}

export default function AffordabilitySignal({ totalAnnual }: Props) {
  const [income, setIncome] = useState("");
  const incomeNum = Number(income.replace(/,/g, "")) * 10000 || 0;
  const ratio = incomeNum > 0 ? totalAnnual / incomeNum : 0;
  const signal = incomeNum > 0 ? getSignal(ratio) : null;

  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5">
      <h3 className="text-sm font-bold mb-3">年収に対して無理はない？</h3>
      <div className="flex items-center gap-2">
        <span className="text-sm text-slate-500 shrink-0">年収</span>
        <input
          type="text"
          inputMode="numeric"
          value={income}
          onChange={(e) => {
            const v = e.target.value.replace(/[^0-9]/g, "");
            setIncome(v);
          }}
          placeholder="例: 400"
          className="w-24 rounded-lg border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 py-1.5 text-sm text-right tabular-nums focus:outline-none focus:ring-2 focus:ring-blue-500/40"
        />
        <span className="text-sm text-slate-400">万円</span>
      </div>

      {signal && (
        <div className={`mt-3 rounded-lg border p-3 ${signal.bg}`}>
          <div className="flex items-center gap-2 mb-1">
            <span className={`text-sm font-bold ${signal.color}`}>
              {signal.label}
            </span>
            <span className="text-xs text-slate-500">
              車の維持費は年収の{" "}
              <span className={`font-bold ${signal.color}`}>
                {Math.round(ratio * 100)}%
              </span>
            </span>
          </div>
          <p className="text-xs text-slate-500">{signal.message}</p>
          <div className="mt-2 flex gap-4 text-xs text-slate-400">
            <span>年間維持費: {formatYen(totalAnnual)}円</span>
            <span>年収: {formatYen(incomeNum)}円</span>
          </div>
          {signal.tips.length > 0 && (
            <div className="mt-3 pt-2 border-t border-slate-200/50 dark:border-slate-700/50">
              <p className="text-[11px] font-semibold text-slate-600 dark:text-slate-300 mb-1.5">
                対応策
              </p>
              <ul className="space-y-1">
                {signal.tips.map((tip) => (
                  <li key={tip} className="text-[11px] text-slate-500 flex items-start gap-1.5">
                    <span className="text-slate-400 shrink-0 mt-0.5">-</span>
                    {tip}
                  </li>
                ))}
              </ul>
              {AFFILIATE_LINKS.carLease.href && (
                <a
                  href={AFFILIATE_LINKS.carLease.href}
                  rel="nofollow sponsored"
                  target="_blank"
                  className="inline-block mt-2 rounded-md bg-emerald-100 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-300 px-3 py-1.5 text-[11px] font-medium hover:bg-emerald-200 dark:hover:bg-emerald-800 transition-colors"
                >
                  カーリースの月額を確認してみる →
                </a>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
