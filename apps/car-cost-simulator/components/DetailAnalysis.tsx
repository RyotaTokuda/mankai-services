"use client";

import { useState } from "react";
import type { CarScenario } from "../lib/types";
import type { calculateCosts } from "../lib/calc";
import PaymentComparison from "./PaymentComparison";
import ResaleComparison from "./ResaleComparison";

interface Props {
  results: { scenario: CarScenario; costs: ReturnType<typeof calculateCosts> }[];
}

export default function DetailAnalysis({ results }: Props) {
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
