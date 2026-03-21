"use client";

import { useState, useEffect } from "react";
import { createPortal } from "react-dom";
import { CAR_MODEL_CATEGORIES } from "../data/car-models";
import type { CarModel } from "../data/car-models";
import { formatYen } from "../lib/calc";

interface Props {
  onSelect: (model: CarModel) => void;
}

export default function CarModelPicker({ onSelect }: Props) {
  const [open, setOpen] = useState(false);
  const [activeCategory, setActiveCategory] = useState(0);

  useEffect(() => {
    if (!open) return;
    function handleKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("keydown", handleKey);
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", handleKey);
      document.body.style.overflow = "";
    };
  }, [open]);

  function handleSelect(model: CarModel) {
    onSelect(model);
    setOpen(false);
  }

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="rounded-xl border-2 border-dashed border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800/60 px-5 py-2 text-sm font-medium text-slate-600 dark:text-slate-300 hover:border-blue-400 hover:text-blue-600 dark:hover:border-blue-500 dark:hover:text-blue-400 transition-colors shadow-sm"
      >
        🚗 車種から選ぶ
      </button>

      {open &&
        createPortal(
          <div
            className="fixed inset-0 z-[9999] flex items-center justify-center p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) setOpen(false);
            }}
          >
            {/* 背景 */}
            <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" />

            {/* モーダル */}
            <div className="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl w-full max-w-2xl max-h-[80vh] flex flex-col overflow-hidden border border-slate-200 dark:border-slate-700">
              {/* ヘッダー */}
              <div className="flex items-center justify-between px-5 py-4 border-b border-slate-200 dark:border-slate-700">
                <h2 className="text-lg font-bold">車種から選ぶ</h2>
                <button
                  onClick={() => setOpen(false)}
                  className="text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 text-xl leading-none"
                  aria-label="閉じる"
                >
                  &times;
                </button>
              </div>

              {/* カテゴリタブ */}
              <div className="flex gap-1 px-5 py-3 border-b border-slate-100 dark:border-slate-800 overflow-x-auto">
                {CAR_MODEL_CATEGORIES.map((cat, i) => (
                  <button
                    key={cat.name}
                    onClick={() => setActiveCategory(i)}
                    className={`shrink-0 rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
                      i === activeCategory
                        ? "bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300"
                        : "text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800"
                    }`}
                  >
                    {cat.icon} {cat.name}
                  </button>
                ))}
              </div>

              {/* 車種リスト */}
              <div className="flex-1 overflow-y-auto px-5 py-3">
                <div className="grid gap-2">
                  {CAR_MODEL_CATEGORIES[activeCategory].models.map((model) => (
                    <button
                      key={model.name}
                      onClick={() => handleSelect(model)}
                      className="flex items-center justify-between rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/60 px-4 py-3 text-left hover:border-blue-400 hover:bg-blue-50 dark:hover:bg-blue-950/30 transition-colors group"
                    >
                      <div>
                        <div className="font-semibold text-sm group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
                          {model.name}
                          <span className="ml-2 text-xs font-normal text-slate-400">
                            {model.maker}
                          </span>
                        </div>
                        <div className="text-xs text-slate-400 mt-0.5">
                          車両価格 {formatYen(model.values.vehiclePrice)}円 / 燃費{" "}
                          {model.values.fuelEfficiency}km/L
                        </div>
                      </div>
                      <span className="text-xs text-slate-400 group-hover:text-blue-500 shrink-0 ml-3">
                        追加 →
                      </span>
                    </button>
                  ))}
                </div>
              </div>

              {/* フッター */}
              <div className="px-5 py-3 border-t border-slate-100 dark:border-slate-800 text-xs text-slate-400 text-center">
                価格・燃費は売れ筋グレードの目安です。実際の値に合わせて調整してください。
              </div>
            </div>
          </div>,
          document.body
        )}
    </>
  );
}
