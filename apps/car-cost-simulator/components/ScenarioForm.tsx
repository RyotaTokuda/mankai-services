"use client";

import { useState } from "react";
import type { CarScenario } from "../lib/types";
import { HELP } from "../lib/help-texts";
import HelpTip from "./HelpTip";
import MaintenanceBreakdown from "./MaintenanceBreakdown";
import TirePicker from "./TirePicker";
import { calculateCosts, formatYen } from "../lib/calc";

interface Props {
  scenario: CarScenario;
  onChange: (scenario: CarScenario) => void;
  onRemove?: () => void;
  canRemove: boolean;
}

function formatWithComma(n: number): string {
  if (n === 0) return "";
  return n.toLocaleString("ja-JP");
}

function NumberField({
  label,
  value,
  onChange,
  unit,
  step,
  helpKey,
}: {
  label: string;
  value: number;
  onChange: (v: number) => void;
  unit?: string;
  step?: number;
  helpKey?: string;
}) {
  const [editing, setEditing] = useState(false);
  const [rawInput, setRawInput] = useState("");

  const display = editing ? rawInput : formatWithComma(value);

  return (
    <div className="flex items-center gap-3 py-2.5 border-b border-slate-100 dark:border-slate-700/50 last:border-0">
      <div className="flex items-center gap-1 min-w-0 flex-1">
        <span className="text-sm text-slate-600 dark:text-slate-400 truncate">
          {label}
        </span>
        {helpKey && HELP[helpKey] && <HelpTip text={HELP[helpKey]} />}
      </div>
      <div className="flex items-center gap-1.5 shrink-0">
        <input
          type="text"
          inputMode="decimal"
          value={display}
          onFocus={() => {
            setEditing(true);
            setRawInput(value === 0 ? "" : String(value));
          }}
          onBlur={() => setEditing(false)}
          onChange={(e) => {
            const raw = e.target.value.replace(/,/g, "");
            setRawInput(raw);
            if (raw === "") {
              onChange(0);
              return;
            }
            const num = Number(raw);
            if (!isNaN(num)) onChange(num);
          }}
          step={step ?? 1}
          className="w-28 rounded-lg border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 py-1.5 text-sm text-right tabular-nums focus:outline-none focus:ring-2 focus:ring-blue-500/40 focus:border-blue-400 transition-shadow"
          placeholder="0"
        />
        {unit && (
          <span className="text-xs text-slate-400 w-10 shrink-0">{unit}</span>
        )}
      </div>
    </div>
  );
}

export default function ScenarioForm({
  scenario,
  onChange,
  onRemove,
  canRemove,
}: Props) {
  const [detailed, setDetailed] = useState(false);

  const costs = calculateCosts({ ...scenario, id: "" });

  function update<K extends keyof CarScenario>(key: K, value: CarScenario[K]) {
    onChange({ ...scenario, [key]: value });
  }

  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm overflow-hidden">
      {/* ヘッダー */}
      <div className="flex items-center justify-between px-5 py-3 bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-950/40 dark:to-cyan-950/40 border-b border-slate-200 dark:border-slate-700">
        <input
          type="text"
          value={scenario.name}
          onChange={(e) => update("name", e.target.value)}
          className="text-base font-bold bg-transparent border-none focus:outline-none focus:ring-0 w-full text-slate-800 dark:text-slate-100"
          placeholder="車種名を入力"
        />
        <div className="flex items-center gap-2 shrink-0 ml-2">
          {canRemove && onRemove && (
            <button
              onClick={onRemove}
              className="text-xs text-red-400 hover:text-red-600 dark:hover:text-red-300 transition-colors"
              aria-label={`${scenario.name}を削除`}
            >
              削除
            </button>
          )}
        </div>
      </div>

      {/* モード切替 */}
      <div className="px-5 py-2.5 border-b border-slate-100 dark:border-slate-700/50">
        <div className="flex items-center gap-1">
          <button
            onClick={() => setDetailed(false)}
            className={`rounded-full px-3.5 py-1.5 text-xs font-medium transition-colors border ${
              !detailed
                ? "bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-700"
                : "bg-slate-100 text-slate-500 border-slate-200 hover:bg-slate-200 hover:text-slate-700 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-600 dark:hover:bg-slate-700"
            }`}
          >
            簡易
          </button>
          <button
            onClick={() => setDetailed(true)}
            className={`rounded-full px-3.5 py-1.5 text-xs font-medium transition-colors border ${
              detailed
                ? "bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-700"
                : "bg-slate-100 text-slate-500 border-slate-200 hover:bg-slate-200 hover:text-slate-700 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-600 dark:hover:bg-slate-700"
            }`}
          >
            詳細
          </button>
        </div>
        <p className="text-[11px] text-slate-400 mt-1.5">
          {detailed
            ? "全項目を細かく設定できます"
            : "主要な項目だけサクッと入力できます"}
        </p>
      </div>

      <div className="divide-y divide-slate-100 dark:divide-slate-700/50">
        {/* ── 簡易モード ── */}
        {!detailed && (
          <>
            <Section icon="💰" title="車両・ローン">
              <NumberField label="車両価格" value={scenario.vehiclePrice} onChange={(v) => update("vehiclePrice", v)} unit="円" step={10000} helpKey="vehiclePrice" />
              <NumberField label="頭金" value={scenario.downPayment} onChange={(v) => update("downPayment", v)} unit="円" step={10000} helpKey="downPayment" />
              <NumberField label="ローン年数" value={scenario.loanYears} onChange={(v) => update("loanYears", v)} unit="年" step={1} helpKey="loanYears" />
              <LoanResult monthly={costs.loanMonthly} total={costs.loanTotal} />
            </Section>

            <Section icon="🏠" title="毎月の固定費">
              <NumberField label="駐車場代" value={scenario.parkingFee} onChange={(v) => update("parkingFee", v)} unit="円/月" step={1000} helpKey="parkingFee" />
              <NumberField label="任意保険" value={scenario.insuranceFee} onChange={(v) => update("insuranceFee", v)} unit="円/月" step={1000} helpKey="insuranceFee" />
            </Section>

            <Section icon="⛽" title="燃料">
              <NumberField label="燃費" value={scenario.fuelEfficiency} onChange={(v) => update("fuelEfficiency", v)} unit="km/L" step={0.1} helpKey="fuelEfficiency" />
              <NumberField label="年間走行距離" value={scenario.annualMileage} onChange={(v) => update("annualMileage", v)} unit="km" step={1000} helpKey="annualMileage" />
            </Section>

            <div className="px-5 py-3">
              <button
                onClick={() => setDetailed(true)}
                className="w-full rounded-lg border border-dashed border-slate-300 dark:border-slate-600 py-2 text-xs text-slate-400 hover:text-blue-600 hover:border-blue-400 dark:hover:text-blue-400 dark:hover:border-blue-500 transition-colors"
              >
                もっと細かく設定する →
              </button>
            </div>
          </>
        )}

        {/* ── 詳細モード ── */}
        {detailed && (
          <>
            <Section icon="💰" title="車両・ローン">
              <NumberField label="車両価格" value={scenario.vehiclePrice} onChange={(v) => update("vehiclePrice", v)} unit="円" step={10000} helpKey="vehiclePrice" />
              <NumberField label="頭金" value={scenario.downPayment} onChange={(v) => update("downPayment", v)} unit="円" step={10000} helpKey="downPayment" />
              <NumberField label="金利" value={scenario.interestRate} onChange={(v) => update("interestRate", v)} unit="%" step={0.1} helpKey="interestRate" />
              <NumberField label="ローン年数" value={scenario.loanYears} onChange={(v) => update("loanYears", v)} unit="年" step={1} helpKey="loanYears" />
              <LoanResult monthly={costs.loanMonthly} total={costs.loanTotal} />
            </Section>

            <Section icon="🏠" title="毎月の固定費">
              <NumberField label="駐車場代" value={scenario.parkingFee} onChange={(v) => update("parkingFee", v)} unit="円/月" step={1000} helpKey="parkingFee" />
              <NumberField label="任意保険" value={scenario.insuranceFee} onChange={(v) => update("insuranceFee", v)} unit="円/月" step={1000} helpKey="insuranceFee" />
            </Section>

            <Section icon="📋" title="年間の費用">
              <NumberField label="自動車税" value={scenario.autoTax} onChange={(v) => update("autoTax", v)} unit="円/年" step={1000} helpKey="autoTax" />
              <NumberField label="車検費用（1回）" value={scenario.inspectionFee} onChange={(v) => update("inspectionFee", v)} unit="円/回" step={10000} helpKey="inspectionFee" />
            </Section>

            <Section icon="🛞" title="タイヤ">
              <NumberField label="タイヤ交換" value={scenario.tireFee} onChange={(v) => update("tireFee", v)} unit="円/年" step={1000} helpKey="tireFee" />
              <TirePicker
                tireFee={scenario.tireFee}
                onChange={(v) => update("tireFee", v)}
                vehiclePrice={scenario.vehiclePrice}
              />
            </Section>

            <Section icon="🔧" title="消耗品・整備">
              <NumberField label="消耗品・整備" value={scenario.maintenanceFee} onChange={(v) => update("maintenanceFee", v)} unit="円/年" step={1000} helpKey="maintenanceFee" />
              <MaintenanceBreakdown
                maintenanceFee={scenario.maintenanceFee}
                onChange={(v) => update("maintenanceFee", v)}
                vehiclePrice={scenario.vehiclePrice}
              />
            </Section>

            <Section icon="⛽" title="燃料">
              <NumberField label="燃費" value={scenario.fuelEfficiency} onChange={(v) => update("fuelEfficiency", v)} unit="km/L" step={0.1} helpKey="fuelEfficiency" />
              <NumberField label="ガソリン単価" value={scenario.fuelPrice} onChange={(v) => update("fuelPrice", v)} unit="円/L" step={1} helpKey="fuelPrice" />
              <NumberField label="年間走行距離" value={scenario.annualMileage} onChange={(v) => update("annualMileage", v)} unit="km" step={1000} helpKey="annualMileage" />
            </Section>
          </>
        )}
      </div>
    </div>
  );
}

function LoanResult({ monthly, total }: { monthly: number; total: number }) {
  if (monthly === 0) return null;
  return (
    <div className="mt-1 mb-1 rounded-lg bg-blue-50/70 dark:bg-blue-950/30 border border-blue-100 dark:border-blue-900 px-3 py-2.5">
      <div className="flex items-center gap-1.5 mb-1.5">
        <span className="text-[10px] font-bold text-blue-500 dark:text-blue-400 bg-blue-100 dark:bg-blue-900 rounded px-1.5 py-0.5">
          試算結果
        </span>
      </div>
      <div className="flex gap-4">
        <div>
          <div className="text-[11px] text-slate-400">毎月の返済額</div>
          <div className="text-sm font-bold text-blue-700 dark:text-blue-300 tabular-nums">
            {formatYen(monthly)}<span className="text-[11px] font-normal ml-0.5">円</span>
          </div>
        </div>
        <div>
          <div className="text-[11px] text-slate-400">年間の返済額</div>
          <div className="text-sm font-bold text-blue-700 dark:text-blue-300 tabular-nums">
            {formatYen(monthly * 12)}<span className="text-[11px] font-normal ml-0.5">円</span>
          </div>
        </div>
        <div>
          <div className="text-[11px] text-slate-400">返済総額</div>
          <div className="text-sm font-bold text-slate-600 dark:text-slate-300 tabular-nums">
            {formatYen(total)}<span className="text-[11px] font-normal ml-0.5">円</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function Section({
  icon,
  title,
  children,
}: {
  icon: string;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="px-5 py-4">
      <div className="flex items-center gap-2 mb-2">
        <span role="img" aria-hidden="true">{icon}</span>
        <h3 className="text-sm font-semibold text-slate-700 dark:text-slate-300">{title}</h3>
      </div>
      <div>{children}</div>
    </div>
  );
}
