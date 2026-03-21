"use client";

import type { CarScenario } from "../lib/types";
import { formatYen } from "../lib/calc";

interface Props {
  scenario: CarScenario;
}

function calcLoanMonthly(
  principal: number,
  rate: number,
  years: number
): number {
  if (principal <= 0 || years <= 0) return 0;
  const monthlyRate = rate / 100 / 12;
  const n = years * 12;
  if (monthlyRate <= 0) return principal / n;
  return (
    (principal * monthlyRate * Math.pow(1 + monthlyRate, n)) /
    (Math.pow(1 + monthlyRate, n) - 1)
  );
}

export default function PaymentComparison({ scenario }: Props) {
  const price = scenario.vehiclePrice;
  const down = scenario.downPayment;
  const rate = scenario.interestRate;
  const years = scenario.loanYears;

  // 現金一括
  const cashTotal = price;

  // 通常ローン
  const loanPrincipal = price - down;
  const loanMonthly = calcLoanMonthly(loanPrincipal, rate, years);
  const loanTotal = down + loanMonthly * years * 12;

  // 残価設定ローン（残価率40%想定、金利は通常+0.5%が一般的）
  const residualRate = 0.4;
  const residualValue = Math.round(price * residualRate);
  const residualPrincipal = price - down - residualValue;
  const residualLoanRate = rate + 0.5;
  const residualMonthly = calcLoanMonthly(
    residualPrincipal,
    residualLoanRate,
    years
  );
  const residualTotalPaid = down + residualMonthly * years * 12;
  // 最終回に残価を一括 or 返却
  const residualTotalBuy = residualTotalPaid + residualValue;

  const methods = [
    {
      name: "現金一括",
      icon: "💵",
      monthly: 0,
      totalCost: cashTotal,
      note: "利息なし。まとまった資金が必要",
      highlight: cashTotal <= loanTotal,
    },
    {
      name: `通常ローン（${years}年）`,
      icon: "🏦",
      monthly: Math.round(loanMonthly),
      totalCost: Math.round(loanTotal),
      note: `金利${rate}% / 頭金${formatYen(down)}円`,
      highlight: false,
    },
    {
      name: `残価設定ローン（${years}年）`,
      icon: "🔄",
      monthly: Math.round(residualMonthly),
      totalCost: Math.round(residualTotalBuy),
      note: `残価${Math.round(residualRate * 100)}%（${formatYen(residualValue)}円）/ 金利${residualLoanRate}%`,
      highlight: false,
      sub: [
        {
          label: "返却する場合",
          value: Math.round(residualTotalPaid),
        },
        {
          label: "買い取る場合",
          value: Math.round(residualTotalBuy),
        },
      ],
    },
  ];

  if (price <= 0) return null;

  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5">
      <h3 className="text-sm font-bold mb-3">
        支払方法の比較（{scenario.name}）
      </h3>
      <div className="grid gap-3 sm:grid-cols-3">
        {methods.map((m) => (
          <div
            key={m.name}
            className={`rounded-xl border p-3 ${
              m.highlight
                ? "border-green-200 dark:border-green-800 bg-green-50/50 dark:bg-green-950/20"
                : "border-slate-100 dark:border-slate-700"
            }`}
          >
            <div className="flex items-center gap-1.5 mb-2">
              <span>{m.icon}</span>
              <span className="text-xs font-semibold">{m.name}</span>
            </div>
            {m.monthly > 0 && (
              <div className="mb-1">
                <span className="text-[11px] text-slate-400">月々</span>
                <span className="text-base font-bold tabular-nums ml-1">
                  {formatYen(m.monthly)}
                </span>
                <span className="text-[11px]">円</span>
              </div>
            )}
            <div>
              <span className="text-[11px] text-slate-400">
                支払総額
              </span>
              <span className="text-sm font-bold tabular-nums ml-1">
                {formatYen(m.totalCost)}
              </span>
              <span className="text-[11px]">円</span>
            </div>
            {m.sub && (
              <div className="mt-1.5 space-y-0.5">
                {m.sub.map((s) => (
                  <div key={s.label} className="text-[11px] text-slate-400">
                    {s.label}:{" "}
                    <span className="tabular-nums font-medium text-slate-600 dark:text-slate-300">
                      {formatYen(s.value)}円
                    </span>
                  </div>
                ))}
              </div>
            )}
            <p className="text-[10px] text-slate-400 mt-2">{m.note}</p>
          </div>
        ))}
      </div>
      <p className="text-[10px] text-slate-400 mt-3">
        ※ 残価設定ローンは残価率40%、金利+0.5%で試算。実際の条件はディーラーにご確認ください。
      </p>
    </div>
  );
}
