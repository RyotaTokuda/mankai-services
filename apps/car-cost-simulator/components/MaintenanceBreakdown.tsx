"use client";

import {
  MAINTENANCE_ITEMS_COMPACT,
  MAINTENANCE_ITEMS_KEI,
  MAINTENANCE_ITEMS_LARGE,
  getTotalAnnualMaintenance,
} from "../data/maintenance-items";
import type { MaintenanceItem } from "../data/maintenance-items";

interface Props {
  maintenanceFee: number;
  onChange: (fee: number) => void;
  vehiclePrice: number;
}

function getItemsForVehicle(vehiclePrice: number): MaintenanceItem[] {
  if (vehiclePrice <= 1900000) return MAINTENANCE_ITEMS_KEI;
  if (vehiclePrice >= 4000000) return MAINTENANCE_ITEMS_LARGE;
  return MAINTENANCE_ITEMS_COMPACT;
}

function getVehicleLabel(vehiclePrice: number): string {
  if (vehiclePrice <= 1900000) return "軽自動車";
  if (vehiclePrice >= 4000000) return "大型車・高級車";
  return "普通車";
}

function formatYen(n: number): string {
  return n.toLocaleString("ja-JP");
}

export default function MaintenanceBreakdown({
  maintenanceFee,
  onChange,
  vehiclePrice,
}: Props) {
  const items = getItemsForVehicle(vehiclePrice);
  const suggestedTotal = getTotalAnnualMaintenance(items);
  const regularItems = items.filter((i) => i.category === "regular");
  const periodicItems = items.filter((i) => i.category === "periodic");

  return (
    <details className="group mt-1">
      <summary className="cursor-pointer text-xs text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 transition-colors flex items-center gap-1 py-1">
        <span className="group-open:rotate-90 transition-transform inline-block text-[10px]">
          ▶
        </span>
        消耗品の内訳を見る（{getVehicleLabel(vehiclePrice)}の目安）
      </summary>

      <div className="mt-2 rounded-lg border border-slate-100 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-800/30 overflow-hidden">
        {/* 定期的な費用 */}
        <div className="px-3 pt-3 pb-1">
          <div className="text-[11px] font-semibold text-blue-600 dark:text-blue-400 mb-1.5">
            こまめにかかる費用（半年〜1年ごと）
          </div>
          {regularItems.map((item) => (
            <ItemRow key={item.key} item={item} />
          ))}
        </div>

        {/* まとまった出費 */}
        <div className="px-3 pt-2 pb-1 border-t border-slate-100 dark:border-slate-700">
          <div className="text-[11px] font-semibold text-amber-600 dark:text-amber-400 mb-1.5">
            数年に1回のまとまった出費
          </div>
          {periodicItems.map((item) => (
            <ItemRow key={item.key} item={item} />
          ))}
        </div>

        {/* 合計・適用ボタン */}
        <div className="px-3 py-2.5 border-t border-slate-200 dark:border-slate-600 bg-slate-100/50 dark:bg-slate-700/30">
          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-500">
              年間合計の目安:
              <span className="font-bold text-slate-700 dark:text-slate-200 ml-1">
                {formatYen(suggestedTotal)}円/年
              </span>
              <span className="text-slate-400 ml-1">
                （月 {formatYen(Math.round(suggestedTotal / 12))}円）
              </span>
            </span>
            {maintenanceFee !== suggestedTotal && (
              <button
                onClick={() => onChange(suggestedTotal)}
                className="rounded-md bg-blue-100 dark:bg-blue-900 px-2.5 py-1 text-blue-700 dark:text-blue-300 font-medium hover:bg-blue-200 dark:hover:bg-blue-800 transition-colors"
              >
                この金額を適用
              </button>
            )}
          </div>
          {maintenanceFee === suggestedTotal && (
            <div className="text-[11px] text-green-600 dark:text-green-400 mt-1">
              目安金額が適用されています
            </div>
          )}
        </div>
      </div>
    </details>
  );
}

function ItemRow({ item }: { item: MaintenanceItem }) {
  return (
    <details className="group/item mb-0.5">
      <summary className="cursor-pointer flex items-center justify-between py-1.5 text-xs hover:bg-slate-100 dark:hover:bg-slate-700/40 rounded px-1 -mx-1 transition-colors">
        <div className="flex items-center gap-2 min-w-0">
          <span
            className={`inline-block w-1.5 h-1.5 rounded-full shrink-0 ${
              item.category === "regular"
                ? "bg-blue-400"
                : "bg-amber-400"
            }`}
          />
          <span className="text-slate-600 dark:text-slate-300 truncate">
            {item.label}
          </span>
        </div>
        <div className="flex items-center gap-2 shrink-0 ml-2">
          <span className="text-slate-400 text-[11px]">
            {item.intervalLabel}
          </span>
          <span className="font-medium tabular-nums text-slate-700 dark:text-slate-200 w-16 text-right">
            {formatYen(item.annualCost)}円
          </span>
        </div>
      </summary>
      <div className="ml-4 mb-2 px-2 py-1.5 text-[11px] text-slate-500 dark:text-slate-400 bg-white dark:bg-slate-800 rounded border border-slate-100 dark:border-slate-700 leading-relaxed">
        <div className="mb-1">
          <span className="font-medium text-slate-600 dark:text-slate-300">
            1回あたり: {formatYen(item.costPerTime)}円
          </span>
        </div>
        {item.note}
      </div>
    </details>
  );
}
