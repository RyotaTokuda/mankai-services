"use client";

import { useState } from "react";
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
  "#3b82f6",
  "#10b981",
  "#f59e0b",
  "#ef4444",
  "#8b5cf6",
];

const CHART_W = 600;
const CHART_H = 260;
const PAD = { top: 15, right: 20, bottom: 30, left: 70 };

interface Hover {
  carName: string;
  year: number;
  value: number;
  x: number;
  y: number;
  color: string;
}

export default function YearlyCostChart({ results }: Props) {
  const [hover, setHover] = useState<Hover | null>(null);

  if (results.length < 2) return null;

  const years = [1, 2, 3, 4, 5];
  const carCount = results.length;
  const cumulativeData = results.map((r) =>
    years.map((y) => r.costs.totalAnnual * y)
  );
  const maxCost = Math.max(...cumulativeData.flat());
  const yMax = Math.ceil(maxCost / 1000000) * 1000000 || 1000000;

  const plotW = CHART_W - PAD.left - PAD.right;
  const plotH = CHART_H - PAD.top - PAD.bottom;

  const groupW = plotW / years.length;
  const barGap = 2;
  const barW = Math.min((groupW - barGap * (carCount + 1)) / carCount, 30);

  function xBar(yearIdx: number, carIdx: number) {
    const groupStart = PAD.left + yearIdx * groupW;
    const barsWidth = carCount * barW + (carCount - 1) * barGap;
    const offset = (groupW - barsWidth) / 2;
    return groupStart + offset + carIdx * (barW + barGap);
  }

  function y(val: number) {
    return PAD.top + plotH - (val / yMax) * plotH;
  }

  const yTicks: number[] = [];
  const tickStep =
    yMax <= 3000000 ? 500000 : yMax <= 10000000 ? 1000000 : 2000000;
  for (let v = 0; v <= yMax; v += tickStep) yTicks.push(v);

  const diff5yr =
    Math.max(...cumulativeData.map((d) => d[4])) -
    Math.min(...cumulativeData.map((d) => d[4]));

  return (
    <div className="mt-6 rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5">
      <h3 className="text-base font-bold mb-4">年ごとの累積コスト比較</h3>

      <div className="relative">
        <svg
          viewBox={`0 0 ${CHART_W} ${CHART_H}`}
          className="w-full h-auto"
          aria-label="年ごとの累積コスト棒グラフ"
          onMouseLeave={() => setHover(null)}
        >
          {/* Y軸グリッド+ラベル */}
          {yTicks.map((v) => (
            <g key={v}>
              <line
                x1={PAD.left}
                y1={y(v)}
                x2={CHART_W - PAD.right}
                y2={y(v)}
                stroke="#e5e7eb"
                strokeWidth={0.5}
              />
              <text
                x={PAD.left - 6}
                y={y(v) + 3}
                textAnchor="end"
                fontSize={10}
                fill="#94a3b8"
              >
                {v >= 10000 ? `${(v / 10000).toLocaleString()}万` : "0"}
              </text>
            </g>
          ))}

          {/* X軸ラベル */}
          {years.map((yr, yi) => (
            <text
              key={yr}
              x={PAD.left + yi * groupW + groupW / 2}
              y={CHART_H - 6}
              textAnchor="middle"
              fontSize={11}
              fill="#94a3b8"
            >
              {yr}年目
            </text>
          ))}

          {/* 棒グラフ */}
          {results.map((r, ri) =>
            years.map((yr, yi) => {
              const val = cumulativeData[ri][yi];
              const barH = (val / yMax) * plotH;
              const bx = xBar(yi, ri);
              const by = y(val);
              const isHovered =
                hover?.carName === r.name && hover?.year === yr;
              return (
                <rect
                  key={`${r.name}-${yi}`}
                  x={bx}
                  y={by}
                  width={barW}
                  height={barH}
                  rx={2}
                  fill={COLORS[ri % COLORS.length]}
                  opacity={isHovered ? 1 : 0.8}
                  stroke={isHovered ? COLORS[ri % COLORS.length] : "none"}
                  strokeWidth={isHovered ? 2 : 0}
                  style={{ cursor: "pointer" }}
                  onMouseEnter={() =>
                    setHover({
                      carName: r.name,
                      year: yr,
                      value: val,
                      x: bx + barW / 2,
                      y: by,
                      color: COLORS[ri % COLORS.length],
                    })
                  }
                />
              );
            })
          )}

          {/* ホバーツールチップ（SVG内） */}
          {hover && (() => {
            const tw = 130;
            const th = 38;
            const tx = Math.max(PAD.left, Math.min(hover.x - tw / 2, CHART_W - PAD.right - tw));
            const ty = Math.max(PAD.top, hover.y - th - 6);
            return (
              <g>
                <rect
                  x={tx}
                  y={ty}
                  width={tw}
                  height={th}
                  rx={6}
                  fill="white"
                  stroke="#e2e8f0"
                  strokeWidth={1}
                  filter="drop-shadow(0 1px 2px rgba(0,0,0,0.08))"
                />
                <text
                  x={tx + tw / 2}
                  y={ty + 15}
                  textAnchor="middle"
                  fontSize={9}
                  fill="#64748b"
                >
                  {hover.carName} {hover.year}年目
                </text>
                <text
                  x={tx + tw / 2}
                  y={ty + 30}
                  textAnchor="middle"
                  fontSize={11}
                  fill={hover.color}
                  fontWeight="bold"
                >
                  {formatYen(hover.value)}円
                </text>
              </g>
            );
          })()}
        </svg>
      </div>

      {/* 凡例 */}
      <div className="flex flex-wrap gap-3 mt-3 pt-3 border-t border-slate-100 dark:border-slate-700">
        {results.map((r, ri) => (
          <div key={r.name} className="flex items-center gap-1.5">
            <span
              className="inline-block w-3 h-3 rounded-sm"
              style={{ backgroundColor: COLORS[ri % COLORS.length] }}
            />
            <span className="text-xs text-slate-500">
              {r.name}
              <span className="ml-1 text-slate-400 tabular-nums">
                （5年: {formatYen(cumulativeData[ri][4])}円）
              </span>
            </span>
          </div>
        ))}
      </div>

      {/* 差額サマリー */}
      <div className="mt-3 rounded-lg bg-amber-50/70 dark:bg-amber-950/30 border border-amber-100 dark:border-amber-900 px-3 py-2.5 text-center">
        <span className="text-xs text-slate-500">5年間で</span>
        <span className="text-base font-bold text-amber-600 dark:text-amber-400 mx-1.5 tabular-nums">
          {formatYen(diff5yr)}円
        </span>
        <span className="text-xs text-slate-500">の差がつきます</span>
      </div>
    </div>
  );
}
