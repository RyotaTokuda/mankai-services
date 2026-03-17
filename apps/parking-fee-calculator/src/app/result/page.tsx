"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { ParkingRules, NoteCategory, NotePriority } from "@mankai/parking-shared";
import { calculateFee } from "@mankai/parking-shared";

// OCR 解析結果がない場合のフォールバック（ダミーデータ）
const FALLBACK_RULES: ParkingRules = {
  name: "サンプル駐車場",
  zones: [
    {
      name: "全車種",
      slots: [
        { startHour: 8, endHour: 22, unitMinutes: 30, unitPrice: 200 },
        { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 100 },
      ],
      maxPrices: [{ amount: 1200, type: "per_day", label: "当日最大" }],
    },
  ],
  notes: [
    { priority: "high", category: "vehicle", text: "車高制限 2.1m 以下" },
    { priority: "high", category: "payment", text: "現金のみ（クレジットカード・電子マネー不可）" },
    { priority: "high", category: "max_price", text: "最大料金は0時リセット。日をまたぐと翌日分が別カウントになります" },
  ],
};

// 旧フォーマット対応マイグレーション
function migrateRules(raw: any): ParkingRules {
  if (raw?.zones) return raw as ParkingRules;
  return {
    name: raw?.name ?? "駐車場",
    zones: [{ name: "全車種", slots: raw?.slots ?? [], maxPrices: raw?.maxPrice ? [raw.maxPrice] : [] }],
    notes: raw?.notes ?? [],
  };
}

const NOTE_ICONS: Record<NoteCategory, string> = {
  max_price: "⚠️",
  vehicle: "🚗",
  payment: "💳",
  reentry: "🔄",
  schedule: "📅",
  discount: "🎟️",
};

const NOTE_STYLES: Record<NotePriority, string> = {
  high: "bg-red-50 border border-red-200 text-red-900",
  medium: "bg-yellow-50 border border-yellow-200 text-yellow-900",
  low: "bg-gray-50 border border-gray-200 text-gray-600",
};

const MAX_PRICE_LABELS: Record<string, string> = {
  per_day: "当日最大（0時リセット）",
  per_24h_once: "24時間最大・1回限り",
  per_24h_repeat: "24時間ごと繰り返し",
  per_period: "時間帯ごと",
};

const pad = (n: number) => String(n).padStart(2, "0");

function roundToTenMinutes(date: Date): Date {
  const d = new Date(date);
  const m = Math.round(d.getMinutes() / 10) * 10;
  if (m >= 60) {
    d.setHours(d.getHours() + 1, 0, 0, 0);
  } else {
    d.setMinutes(m, 0, 0);
  }
  return d;
}

function toDateStr(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

function toTimeStr(date: Date): string {
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function combineDateTime(dateStr: string, timeStr: string): Date {
  return new Date(`${dateStr}T${timeStr}`);
}

function loadRulesFromSession(): ParkingRules {
  if (typeof window === "undefined") return FALLBACK_RULES;
  const stored = sessionStorage.getItem("parkingRules");
  if (!stored) return FALLBACK_RULES;
  try {
    return JSON.parse(stored) as ParkingRules;
  } catch {
    return FALLBACK_RULES;
  }
}

export default function ResultPage() {
  const [entryDate, setEntryDate] = useState(() =>
    toDateStr(roundToTenMinutes(new Date()))
  );
  const [entryTime, setEntryTime] = useState(() =>
    toTimeStr(roundToTenMinutes(new Date()))
  );
  const [exitDate, setExitDate] = useState(() => {
    const later = new Date();
    later.setHours(later.getHours() + 2);
    return toDateStr(roundToTenMinutes(later));
  });
  const [exitTime, setExitTime] = useState(() => {
    const later = new Date();
    later.setHours(later.getHours() + 2);
    return toTimeStr(roundToTenMinutes(later));
  });

  // sessionStorage からアップロード画像・解析結果を取得（lazy initializer で SSR 対応）
  const [imageUrl] = useState<string | null>(() => {
    if (typeof window === "undefined") return null;
    return sessionStorage.getItem("uploadedImageUrl");
  });

  const [rules] = useState<ParkingRules>(() => migrateRules(loadRulesFromSession()));

  // OCR で解析されたか、フォールバックかを判定
  const isOcrResult = useMemo(() => {
    if (typeof window === "undefined") return false;
    return sessionStorage.getItem("parkingRules") !== null;
  }, []);

  // 先頭ゾーンで計算（Web版は1ゾーン表示）
  const zone = rules.zones[0] ?? { name: "全車種", slots: [], maxPrices: [] };

  const result = useMemo(() => {
    const entry = combineDateTime(entryDate, entryTime);
    const exit = combineDateTime(exitDate, exitTime);
    if (isNaN(entry.getTime()) || isNaN(exit.getTime())) return null;
    return calculateFee(entry, exit, zone);
  }, [entryDate, entryTime, exitDate, exitTime, zone]);

  const sortedNotes = [...rules.notes].sort((a, b) => {
    const order: Record<NotePriority, number> = { high: 0, medium: 1, low: 2 };
    return order[a.priority] - order[b.priority];
  });

  return (
    <main className="flex min-h-screen flex-col items-center bg-gray-50 px-4 py-8">
      <div className="w-full max-w-md space-y-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-gray-900">{rules.name}</h1>
          {!isOcrResult && (
            <span className="text-xs text-gray-400 bg-gray-100 rounded-lg px-2 py-1">
              サンプルデータ
            </span>
          )}
        </div>

        {/* 解析した看板画像 */}
        {imageUrl && (
          <section className="rounded-2xl overflow-hidden border border-gray-200">
            <Image
              src={imageUrl}
              alt="解析した看板画像"
              width={400}
              height={200}
              className="w-full object-contain bg-white max-h-48"
            />
          </section>
        )}

        {/* 時間入力 */}
        <section className="rounded-2xl bg-white border border-gray-200 p-4 space-y-4">
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
            駐車予定
          </p>
          <div className="space-y-3">
            <label className="block">
              <span className="text-sm text-gray-600">入庫</span>
              <div className="mt-1 flex gap-2">
                <input
                  type="date"
                  value={entryDate}
                  onChange={(e) => setEntryDate(e.target.value)}
                  className="flex-1 rounded-xl border border-gray-300 px-3 py-2 text-base text-gray-900"
                />
                <input
                  type="time"
                  step="600"
                  value={entryTime}
                  onChange={(e) => setEntryTime(e.target.value)}
                  className="w-28 rounded-xl border border-gray-300 px-3 py-2 text-base text-gray-900"
                />
              </div>
            </label>
            <label className="block">
              <span className="text-sm text-gray-600">出庫（予定）</span>
              <div className="mt-1 flex gap-2">
                <input
                  type="date"
                  value={exitDate}
                  onChange={(e) => setExitDate(e.target.value)}
                  className="flex-1 rounded-xl border border-gray-300 px-3 py-2 text-base text-gray-900"
                />
                <input
                  type="time"
                  step="600"
                  value={exitTime}
                  onChange={(e) => setExitTime(e.target.value)}
                  className="w-28 rounded-xl border border-gray-300 px-3 py-2 text-base text-gray-900"
                />
              </div>
            </label>
          </div>
        </section>

        {/* 算出料金 */}
        {result && (
          <section className="rounded-2xl bg-blue-600 p-5 text-white">
            <p className="text-sm font-medium opacity-80">想定料金</p>
            <p className="mt-1 text-5xl font-bold tracking-tight">
              ¥{result.total.toLocaleString()}
            </p>
            {result.maxPricesApplied.length > 0 && (
              <div className="mt-2 flex flex-wrap gap-1.5">
                {result.maxPricesApplied.map((lbl, i) => (
                  <span key={i} className="inline-block rounded-lg bg-white/20 px-3 py-1 text-sm font-semibold">
                    {lbl}が適用されました
                  </span>
                ))}
              </div>
            )}
            {result.breakdown.length > 0 && (
              <div className="mt-4 space-y-1 border-t border-white/20 pt-3">
                <p className="text-xs opacity-70">内訳</p>
                {result.breakdown.map((b, i) => (
                  <div key={i} className="flex justify-between text-sm">
                    <span className="opacity-80">{b.label}（{b.minutes}分）</span>
                    <span className="font-semibold">¥{b.subtotal.toLocaleString()}</span>
                  </div>
                ))}
                {result.rawTotal !== result.total && (
                  <div className="flex justify-between border-t border-white/20 pt-1 text-sm">
                    <span className="opacity-80">最大料金適用前</span>
                    <span className="line-through opacity-60">¥{result.rawTotal.toLocaleString()}</span>
                  </div>
                )}
              </div>
            )}
          </section>
        )}

        {/* 料金ルール（参照用） */}
        <section className="rounded-2xl bg-white border border-gray-200 p-4">
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
            料金ルール
          </p>
          <ul className="mt-3 space-y-2">
            {zone.slots.map((slot, i) => (
              <li key={i} className="flex items-center justify-between">
                <span className="text-sm text-gray-600">
                  {slot.startHour}:00〜{slot.endHour === 24 ? "24:00" : `${slot.endHour}:00`}
                </span>
                <span className="text-base font-semibold text-gray-900">
                  ¥{slot.unitPrice} / {slot.unitMinutes}分
                </span>
              </li>
            ))}
          </ul>
          {zone.maxPrices.length > 0 && (
            <div className="mt-3 border-t border-gray-100 pt-3 space-y-2">
              {zone.maxPrices.map((mp, i) => (
                <div key={i} className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">
                    {mp.label ?? MAX_PRICE_LABELS[mp.type] ?? mp.type}
                  </span>
                  <span className="text-base font-semibold text-gray-900">
                    上限 ¥{mp.amount.toLocaleString()}
                  </span>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* 注意事項（看板から読み取れた内容のみ） */}
        {sortedNotes.length > 0 && (
          <section className="space-y-2">
            <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
              注意事項
            </p>
            {sortedNotes.map((note, i) => (
              <div
                key={i}
                className={`rounded-xl px-4 py-3 text-sm ${NOTE_STYLES[note.priority]}`}
              >
                <span className="mr-2">{NOTE_ICONS[note.category]}</span>
                {note.text}
              </div>
            ))}
          </section>
        )}

        <Link
          href="/upload"
          className="flex h-12 w-full items-center justify-center rounded-2xl border border-gray-300 bg-white text-sm font-semibold text-gray-700 active:bg-gray-50"
        >
          別の看板を読み取る
        </Link>
      </div>
    </main>
  );
}
