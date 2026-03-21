"use client";

import type { CostBreakdown } from "../lib/types";
import { formatYen } from "../lib/calc";

interface Props {
  name: string;
  costs: CostBreakdown;
}

export default function CostSummary({ name, costs }: Props) {
  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm overflow-hidden">
      <div className="px-5 py-3 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-950/40 dark:to-teal-950/40 border-b border-slate-200 dark:border-slate-700">
        <h3 className="text-base font-bold text-slate-800 dark:text-slate-100">
          {name}
        </h3>
      </div>

      <div className="p-5 space-y-4">
        {/* 主要な数値 */}
        <div className="grid grid-cols-3 gap-3">
          <SummaryCard label="月額" value={costs.totalMonthly} accent />
          <SummaryCard label="年額" value={costs.totalAnnual} />
          <SummaryCard label="5年総額" value={costs.totalFiveYear} large />
        </div>

        {/* 内訳 */}
        <details className="group">
          <summary className="cursor-pointer text-sm text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 transition-colors flex items-center gap-1">
            <span className="group-open:rotate-90 transition-transform inline-block">▶</span>
            内訳を表示
          </summary>
          <div className="mt-3 space-y-0 rounded-lg border border-slate-100 dark:border-slate-700 overflow-hidden">
            <Row label="ローン返済" monthly={costs.loanMonthly} />
            <Row label="駐車場代" monthly={costs.parkingAnnual / 12} />
            <Row label="任意保険" monthly={costs.insuranceAnnual / 12} />
            <Row label="自動車税" monthly={costs.autoTax / 12} />
            <Row label="車検" monthly={costs.inspectionAnnual / 12} />
            <Row label="燃料費" monthly={costs.fuelAnnual / 12} />
            <Row label="タイヤ" monthly={costs.tireAnnual / 12} />
            <Row label="消耗品・整備" monthly={costs.maintenanceAnnual / 12} />
          </div>
        </details>
      </div>
    </div>
  );
}

function SummaryCard({
  label,
  value,
  accent,
  large,
}: {
  label: string;
  value: number;
  accent?: boolean;
  large?: boolean;
}) {
  return (
    <div
      className={`rounded-xl p-3 text-center transition-shadow ${
        accent
          ? "bg-blue-50 dark:bg-blue-950/60 ring-2 ring-blue-200 dark:ring-blue-800 shadow-sm"
          : large
            ? "bg-amber-50 dark:bg-amber-950/40 ring-1 ring-amber-200 dark:ring-amber-800"
            : "bg-slate-50 dark:bg-slate-800"
      }`}
    >
      <div className="text-[11px] text-slate-400 mb-0.5">{label}</div>
      <div
        className={`text-lg font-bold tabular-nums ${
          accent
            ? "text-blue-600 dark:text-blue-400"
            : large
              ? "text-amber-600 dark:text-amber-400"
              : "text-slate-700 dark:text-slate-200"
        }`}
      >
        {formatYen(value)}
        <span className="text-xs font-normal ml-0.5">円</span>
      </div>
    </div>
  );
}

function Row({ label, monthly }: { label: string; monthly: number }) {
  return (
    <div className="flex justify-between py-2 px-3 text-sm even:bg-slate-50 dark:even:bg-slate-800/40">
      <span className="text-slate-500 dark:text-slate-400">{label}</span>
      <span className="font-medium tabular-nums">
        {formatYen(Math.round(monthly))} 円/月
      </span>
    </div>
  );
}
