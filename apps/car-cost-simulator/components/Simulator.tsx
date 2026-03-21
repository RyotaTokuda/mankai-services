"use client";

import { useState, useEffect } from "react";
import type { CarScenario } from "../lib/types";
import { DEFAULT_SCENARIO } from "../lib/types";
import { decodeScenarios, buildShareUrl } from "../lib/url-share";
import { TEMPLATES } from "../data/templates";
import type { CarModel } from "../data/car-models";
import { calculateCosts, formatYen } from "../lib/calc";
import ScenarioForm from "./ScenarioForm";
import CostSummary from "./CostSummary";
import CostChart from "./CostChart";
import CarModelPicker from "./CarModelPicker";
import AffiliateCta from "./AffiliateCta";
import YearlyCostChart from "./YearlyCostChart";
import AffordabilitySignal from "./AffordabilitySignal";
import PaymentComparison from "./PaymentComparison";
import ResaleComparison from "./ResaleComparison";

function createScenario(index: number): CarScenario {
  return {
    ...DEFAULT_SCENARIO,
    id: crypto.randomUUID(),
    name: `車種 ${index}`,
  };
}

/** デフォルトの「車種 1」が未編集かどうか */
function isUntouchedDefault(s: CarScenario): boolean {
  return (
    s.name.startsWith("車種 ") &&
    s.vehiclePrice === DEFAULT_SCENARIO.vehiclePrice &&
    s.downPayment === DEFAULT_SCENARIO.downPayment &&
    s.loanYears === DEFAULT_SCENARIO.loanYears
  );
}

export default function Simulator() {
  const [scenarios, setScenarios] = useState<CarScenario[]>([
    createScenario(1),
  ]);
  const [copied, setCopied] = useState(false);

  // URLからシナリオ復元
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const encoded = params.get("s");
    if (encoded) {
      const restored = decodeScenarios(encoded);
      if (restored && restored.length > 0) setScenarios(restored);
    }
  }, []);

  function handlePdf() {
    import("../lib/pdf-export").then(({ exportPdf }) => exportPdf(results));
  }

  function handleShare() {
    const url = buildShareUrl(scenarios);
    navigator.clipboard.writeText(url).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }

  function updateScenario(id: string, updated: CarScenario) {
    setScenarios((prev) => prev.map((s) => (s.id === id ? updated : s)));
  }

  function addScenario() {
    setScenarios((prev) => [...prev, createScenario(prev.length + 1)]);
  }

  /** テンプレート/車種追加時、未編集のデフォルトがあれば置き換える */
  function addOrReplace(newScenario: CarScenario) {
    setScenarios((prev) => {
      if (prev.length === 1 && isUntouchedDefault(prev[0])) {
        return [newScenario];
      }
      return [...prev, newScenario];
    });
  }

  function addFromTemplate(templateIndex: number) {
    const t = TEMPLATES[templateIndex];
    addOrReplace({ ...t.values, id: crypto.randomUUID(), name: t.name });
  }

  function addFromCarModel(model: CarModel) {
    addOrReplace({ ...model.values, id: crypto.randomUUID() });
  }

  function removeScenario(id: string) {
    setScenarios((prev) => prev.filter((s) => s.id !== id));
  }

  const results = scenarios.map((s) => ({
    scenario: s,
    costs: calculateCosts(s),
  }));

  return (
    <div className="mx-auto max-w-7xl px-4 py-8 space-y-10">
      {/* ヒーロー */}
      <section className="text-center space-y-3">
        <h2 className="text-2xl sm:text-3xl font-extrabold bg-gradient-to-r from-blue-600 to-cyan-500 bg-clip-text text-transparent">
          買う前にわかる、車のリアルなコスト
        </h2>
        <p className="text-sm text-slate-500 dark:text-slate-400 max-w-lg mx-auto">
          ローン・保険・駐車場・燃料・車検をまとめて入力するだけ。月額・年額・5年総額を即座に試算して、複数車種を並べて比較できます。
        </p>
      </section>

      {/* テンプレート・車種選択 */}
      <section className="space-y-4">
        <div>
          <h2 className="text-sm font-semibold text-slate-500 dark:text-slate-400 mb-3">
            カテゴリから追加
          </h2>
          <div className="flex flex-wrap gap-2">
            {TEMPLATES.map((t, i) => (
              <button
                key={t.name}
                onClick={() => addFromTemplate(i)}
                className="rounded-lg border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 py-2 text-sm hover:border-blue-400 hover:bg-blue-50 dark:hover:bg-blue-950/40 transition-colors shadow-sm"
              >
                <span className="mr-1">{t.icon}</span>
                {t.name}
              </button>
            ))}
          </div>
        </div>
        <div>
          <h2 className="text-sm font-semibold text-slate-500 dark:text-slate-400 mb-3">
            人気車種から追加
          </h2>
          <CarModelPicker onSelect={addFromCarModel} />
        </div>
      </section>

      {/* 入力エリア */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold">試算条件</h2>
          <button
            onClick={addScenario}
            className="rounded-xl bg-gradient-to-r from-blue-600 to-cyan-600 px-5 py-2 text-sm font-medium text-white hover:from-blue-700 hover:to-cyan-700 transition-all shadow-md shadow-blue-200 dark:shadow-blue-900/30"
          >
            + 車種を追加
          </button>
        </div>

        <div
          className={`grid gap-6 ${
            scenarios.length > 1 ? "lg:grid-cols-2" : "max-w-2xl"
          }`}
        >
          {scenarios.map((s) => (
            <ScenarioForm
              key={s.id}
              scenario={s}
              onChange={(updated) => updateScenario(s.id, updated)}
              onRemove={() => removeScenario(s.id)}
              canRemove={scenarios.length > 1}
            />
          ))}
        </div>
      </section>

      {/* 結果エリア */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold">試算結果</h2>
          <div className="flex gap-2">
            <button
              onClick={handlePdf}
              className="rounded-lg border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 py-1.5 text-xs text-slate-500 hover:text-blue-600 hover:border-blue-400 transition-colors"
            >
              PDFで保存
            </button>
            <button
              onClick={handleShare}
              className="rounded-lg border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 py-1.5 text-xs text-slate-500 hover:text-blue-600 hover:border-blue-400 transition-colors"
            >
              {copied ? "コピーしました" : "URLで共有"}
            </button>
          </div>
        </div>

        <div
          className={`grid gap-6 ${
            results.length > 1 ? "lg:grid-cols-2" : "max-w-2xl"
          }`}
        >
          {results.map(({ scenario, costs }) => (
            <div key={scenario.id} className="space-y-4">
              <CostSummary name={scenario.name} costs={costs} />
              <CostChart costs={costs} />
            </div>
          ))}
        </div>

        {/* 比較テーブル（2台以上） */}
        {results.length > 1 && (
          <div className="mt-8 rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5 overflow-x-auto">
            <h3 className="text-base font-bold mb-4">比較</h3>
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b-2 border-slate-200 dark:border-slate-600">
                  <th className="text-left py-2 pr-4" />
                  {results.map(({ scenario }) => (
                    <th
                      key={scenario.id}
                      className="text-right py-2 px-3 font-semibold"
                    >
                      {scenario.name}
                    </th>
                  ))}
                  <th className="text-right py-2 pl-3 font-semibold text-slate-400">
                    差額
                  </th>
                </tr>
              </thead>
              <tbody>
                <CompareRow
                  label="月額"
                  values={results.map((r) => r.costs.totalMonthly)}
                />
                <CompareRow
                  label="年額"
                  values={results.map((r) => r.costs.totalAnnual)}
                />
                <CompareRow
                  label="5年総額"
                  values={results.map((r) => r.costs.totalFiveYear)}
                  highlight
                />
                <CompareRow
                  label="ローン月額"
                  values={results.map((r) => r.costs.loanMonthly)}
                />
                <CompareRow
                  label="燃料費/年"
                  values={results.map((r) => r.costs.fuelAnnual)}
                />
              </tbody>
            </table>
          </div>
        )}

        {/* 年ごとの累積コスト比較 */}
        {results.length > 1 && (
          <YearlyCostChart
            results={results.map(({ scenario, costs }) => ({
              name: scenario.name,
              costs,
            }))}
          />
        )}
      </section>

      {/* 詳細分析（車種切替） */}
      <DetailAnalysis results={results} />

      {/* 年収チェック（選択中の車種） */}
      <AffordabilitySignal totalAnnual={results[0].costs.totalAnnual} />

      {/* アフィリエイト導線 */}
      <AffiliateCta costs={results[0].costs} />
    </div>
  );
}

function CompareRow({
  label,
  values,
  highlight,
}: {
  label: string;
  values: number[];
  highlight?: boolean;
}) {
  const min = Math.min(...values);
  const max = Math.max(...values);
  const diff = max - min;

  return (
    <tr
      className={`border-b border-slate-100 dark:border-slate-700 ${
        highlight ? "font-bold bg-amber-50/50 dark:bg-amber-950/20" : ""
      }`}
    >
      <td className="py-2.5 pr-4 text-slate-500">{label}</td>
      {values.map((v, i) => (
        <td
          key={i}
          className={`text-right py-2.5 px-3 tabular-nums ${
            values.length > 1 && v === min
              ? "text-green-600 dark:text-green-400"
              : ""
          }`}
        >
          {formatYen(v)} 円
        </td>
      ))}
      <td className="text-right py-2.5 pl-3 text-slate-400 tabular-nums">
        {values.length > 1 ? `${formatYen(diff)} 円` : "-"}
      </td>
    </tr>
  );
}

function DetailAnalysis({
  results,
}: {
  results: { scenario: CarScenario; costs: ReturnType<typeof calculateCosts> }[];
}) {
  const [selectedIdx, setSelectedIdx] = useState(0);
  const selected = results[selectedIdx];
  if (!selected) return null;

  return (
    <section className="space-y-4">
      <div className="flex items-center gap-3 flex-wrap">
        <h2 className="text-lg font-bold">詳細分析</h2>
        {results.length > 1 && (
          <div className="flex gap-1.5">
            {results.map(({ scenario }, i) => (
              <button
                key={scenario.id}
                onClick={() => setSelectedIdx(i)}
                className={`rounded-full px-3.5 py-1.5 text-xs font-medium transition-colors border ${
                  i === selectedIdx
                    ? "bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-700"
                    : "bg-slate-100 text-slate-500 border-slate-200 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-600"
                }`}
              >
                {scenario.name}
              </button>
            ))}
          </div>
        )}
      </div>

      <PaymentComparison scenario={selected.scenario} />
      <ResaleComparison scenario={selected.scenario} costs={selected.costs} />
    </section>
  );
}
