"use client";

import { useState } from "react";
import { TIRE_OPTIONS } from "../data/tire-options";
import type { TireGrade } from "../data/tire-options";

interface Props {
  tireFee: number;
  onChange: (fee: number) => void;
  vehiclePrice: number;
}

function formatYen(n: number): string {
  return n.toLocaleString("ja-JP");
}

/** カテゴリ → タイヤサイズインデックスのマッピング */
const CATEGORY_OPTIONS = [
  { label: "軽自動車", icon: "🚙", sizeIdx: 0 },
  { label: "コンパクト", icon: "🚗", sizeIdx: 1 },
  { label: "セダン", icon: "🚘", sizeIdx: 2 },
  { label: "ミニバン", icon: "🚐", sizeIdx: 3 },
  { label: "SUV", icon: "🏔️", sizeIdx: 5 },
  { label: "大型SUV", icon: "✨", sizeIdx: 8 },
] as const;

function getCategoryFromPrice(vehiclePrice: number): number {
  if (vehiclePrice <= 1900000) return 0;
  if (vehiclePrice <= 2200000) return 1;
  if (vehiclePrice <= 3000000) return 2;
  if (vehiclePrice <= 3800000) return 3;
  if (vehiclePrice <= 5500000) return 4;
  return 5;
}

export default function TirePicker({ tireFee, onChange, vehiclePrice }: Props) {
  const suggestedCat = getCategoryFromPrice(vehiclePrice);
  const [catIdx, setCatIdx] = useState(suggestedCat);
  const sizeIdx = CATEGORY_OPTIONS[catIdx].sizeIdx;
  const tireSize = TIRE_OPTIONS[sizeIdx];

  const matchedGrade = tireSize?.grades.find((g) => g.annualCost === tireFee);

  return (
    <details className="group mt-1">
      <summary className="cursor-pointer text-xs text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 transition-colors flex items-center gap-1 py-1">
        <span className="group-open:rotate-90 transition-transform inline-block text-[10px]">
          ▶
        </span>
        タイヤの候補から選ぶ
      </summary>

      <div className="mt-2 rounded-lg border border-slate-100 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-800/30 overflow-hidden">
        {/* カテゴリ選択（簡易） */}
        <div className="px-3 pt-3 pb-2">
          <div className="text-[11px] font-semibold text-slate-600 dark:text-slate-300 mb-2">
            車のタイプ
          </div>
          <div className="flex flex-wrap gap-1.5">
            {CATEGORY_OPTIONS.map((cat, i) => (
              <button
                key={cat.label}
                onClick={() => setCatIdx(i)}
                className={`rounded-md px-2.5 py-1.5 text-xs border transition-colors ${
                  i === catIdx
                    ? "border-blue-400 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-600 font-medium"
                    : "border-slate-200 dark:border-slate-600 text-slate-500 hover:border-slate-400"
                }`}
              >
                <span className="mr-1">{cat.icon}</span>
                {cat.label}
              </button>
            ))}
          </div>
          {tireSize && (
            <div className="text-[11px] text-slate-400 mt-1.5">
              {tireSize.fitFor}（{tireSize.size}）
            </div>
          )}
        </div>

        {/* グレード選択 */}
        {tireSize && (
          <div className="px-3 pb-2 border-t border-slate-100 dark:border-slate-700 pt-2">
            <div className="text-[11px] font-semibold text-slate-600 dark:text-slate-300 mb-2">
              グレード
            </div>
            <div className="grid gap-1.5">
              {tireSize.grades.map((g) => (
                <GradeCard
                  key={g.grade}
                  grade={g}
                  selected={matchedGrade?.grade === g.grade}
                  onSelect={() => onChange(g.annualCost)}
                />
              ))}
            </div>
          </div>
        )}

        {/* タイヤサイズで詳しく選ぶ（折りたたみ） */}
        <DetailedSizePicker
          tireFee={tireFee}
          onChange={onChange}
          currentSizeIdx={sizeIdx}
        />

        {/* 注記 */}
        <div className="px-3 py-2 border-t border-slate-200 dark:border-slate-600 bg-slate-100/50 dark:bg-slate-700/30 text-[11px] text-slate-400">
          価格は4本セット+交換工賃の目安。上の金額欄で直接入力もできます。
        </div>
      </div>
    </details>
  );
}

/** タイヤサイズから詳しく選ぶ（折りたたみ） */
function DetailedSizePicker({
  tireFee,
  onChange,
  currentSizeIdx,
}: {
  tireFee: number;
  onChange: (fee: number) => void;
  currentSizeIdx: number;
}) {
  const [open, setOpen] = useState(false);
  const [sizeIdx, setSizeIdx] = useState(currentSizeIdx);
  const tireSize = TIRE_OPTIONS[sizeIdx];
  const matchedGrade = tireSize?.grades.find((g) => g.annualCost === tireFee);

  return (
    <div className="border-t border-slate-100 dark:border-slate-700">
      <button
        onClick={() => setOpen((v) => !v)}
        className="w-full px-3 py-2 text-[11px] text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 transition-colors flex items-center gap-1"
      >
        <span
          className={`transition-transform inline-block text-[10px] ${open ? "rotate-90" : ""}`}
        >
          ▶
        </span>
        タイヤサイズから詳しく選ぶ
      </button>

      {open && (
        <div className="px-3 pb-2">
          <div className="flex flex-wrap gap-1.5 mb-2">
            {TIRE_OPTIONS.map((opt, i) => (
              <button
                key={opt.size}
                onClick={() => setSizeIdx(i)}
                className={`rounded-md px-2 py-1 text-[11px] border transition-colors ${
                  i === sizeIdx
                    ? "border-blue-400 bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-600 font-medium"
                    : "border-slate-200 dark:border-slate-600 text-slate-500 hover:border-slate-400"
                }`}
              >
                {opt.size}
              </button>
            ))}
          </div>
          {tireSize && (
            <>
              <div className="text-[11px] text-slate-400 mb-2">
                {tireSize.fitFor}
              </div>
              <div className="grid gap-1.5">
                {tireSize.grades.map((g) => (
                  <GradeCard
                    key={g.grade}
                    grade={g}
                    selected={matchedGrade?.grade === g.grade}
                    onSelect={() => onChange(g.annualCost)}
                  />
                ))}
              </div>
            </>
          )}
        </div>
      )}
    </div>
  );
}

function GradeCard({
  grade,
  selected,
  onSelect,
}: {
  grade: TireGrade;
  selected: boolean;
  onSelect: () => void;
}) {
  const gradeColors = {
    economy:
      "bg-green-50 border-green-200 dark:bg-green-950/30 dark:border-green-800",
    standard:
      "bg-blue-50 border-blue-200 dark:bg-blue-950/30 dark:border-blue-800",
    premium:
      "bg-purple-50 border-purple-200 dark:bg-purple-950/30 dark:border-purple-800",
  };
  const gradeAccent = {
    economy: "text-green-700 dark:text-green-400",
    standard: "text-blue-700 dark:text-blue-400",
    premium: "text-purple-700 dark:text-purple-400",
  };

  return (
    <button
      onClick={onSelect}
      className={`rounded-lg border px-3 py-2 text-left transition-all ${
        selected
          ? `${gradeColors[grade.grade]} ring-2 ring-offset-1 ${
              grade.grade === "economy"
                ? "ring-green-400"
                : grade.grade === "standard"
                  ? "ring-blue-400"
                  : "ring-purple-400"
            }`
          : "border-slate-200 dark:border-slate-600 hover:border-slate-400"
      }`}
    >
      <div className="flex items-center justify-between">
        <div>
          <span className={`text-xs font-semibold ${gradeAccent[grade.grade]}`}>
            {grade.label}
          </span>
          <span className="text-[11px] text-slate-400 ml-2">
            {grade.brandExample}
          </span>
        </div>
        <div className="text-right shrink-0 ml-2">
          <div className="text-xs font-bold tabular-nums">
            {formatYen(grade.annualCost)}円/年
          </div>
          <div className="text-[10px] text-slate-400 tabular-nums">
            4本 {formatYen(grade.price4set)}円 / {grade.lifeYears}年交換
          </div>
        </div>
      </div>
      <div className="text-[11px] text-slate-500 dark:text-slate-400 mt-1">
        {grade.note}
      </div>
    </button>
  );
}
