import { ParkingZone, TimeSlot } from "../types/parking";

export type FeeBreakdown = {
  dateKey: string;          // "2026-03-15"（per_day の日別集計に使用）
  windowIndex: number;      // 入庫からの24h窓インデックス（per_24h_repeat に使用）
  slotStartHour: number;    // スロットの開始時 （per_period の照合に使用）
  slotEndHour: number;      // スロットの終了時（per_period の照合に使用）
  segmentStartHour: number; // このセグメントの実際の開始時（夜間セグメントの日付判定に使用）
  label: string;            // "8:00〜22:00"
  minutes: number;
  unitPrice: number;
  unitMinutes: number;
  subtotal: number;
};

export type FeeResult = {
  total: number;
  breakdown: FeeBreakdown[];
  maxPricesApplied: string[]; // 適用された最大料金のラベル一覧
  rawTotal: number;
};

function toDateKey(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function getApplicableSlot(date: Date, slots: TimeSlot[]): TimeSlot | null {
  const hour = date.getHours();
  const day = date.getDay() as 0 | 1 | 2 | 3 | 4 | 5 | 6;

  for (const slot of slots) {
    if (slot.daysOfWeek && !slot.daysOfWeek.includes(day)) continue;

    if (slot.startHour < slot.endHour) {
      if (hour >= slot.startHour && hour < slot.endHour) return slot;
    } else {
      // 日跨ぎスロット（例: 22〜8）
      if (hour >= slot.startHour || hour < slot.endHour) return slot;
    }
  }
  return null;
}

function getNextSlotBoundary(current: Date, slots: TimeSlot[], extraHours: number[] = []): Date {
  const currentHour = current.getHours();

  // 0時を常に境界に含める → per_day の日別集計が正確になる
  const hours = new Set<number>([0]);
  for (const slot of slots) {
    hours.add(slot.startHour);
    hours.add(slot.endHour % 24); // 24 → 0（翌0時）
  }
  // per_period のキャップ境界（昼間/夜間の切れ目）も境界に追加
  for (const h of extraHours) hours.add(h);

  const sorted = Array.from(hours).sort((a, b) => a - b);
  const nextHour = sorted.find((h) => h > currentHour);

  const next = new Date(current);
  next.setMinutes(0, 0, 0);

  if (nextHour !== undefined) {
    next.setHours(nextHour);
  } else {
    next.setDate(next.getDate() + 1);
    next.setHours(sorted[0]);
  }

  return next;
}

// per_period の「どの区間のインスタンスか」を示すキーを返す
// 日跨ぎスロット（22〜8 など）では、0時以降のセグメントは前日の夜間に属するとみなす
function getPeriodInstanceKey(b: FeeBreakdown, slotStart: number, slotEnd: number): string {
  const crossesMidnight = slotStart > slotEnd;
  if (!crossesMidnight) {
    // 昼間スロット：dateKey がそのままインスタンスキー
    return b.dateKey;
  }
  // 夜間スロット：0:00〜slotEnd の間は「前の日の夜」に属する
  if (b.segmentStartHour < slotEnd) {
    const [y, m, d] = b.dateKey.split("-").map(Number);
    const prev = new Date(y, m - 1, d - 1);
    return toDateKey(prev);
  }
  return b.dateKey;
}

export function calculateFee(
  entry: Date,
  exit: Date,
  zone: ParkingZone
): FeeResult {
  if (exit <= entry) {
    return { total: 0, breakdown: [], maxPricesApplied: [], rawTotal: 0 };
  }

  // per_period のキャップ境界時刻をスロット境界に追加する
  // （例: オールタイムスロットでも昼間/夜間の境界でセグメントを分割するため）
  const periodBoundaryHours: number[] = [];
  for (const rule of zone.maxPrices) {
    if (rule.type !== "per_period") continue;
    if (rule.startHour !== undefined) periodBoundaryHours.push(rule.startHour);
    if (rule.endHour !== undefined) periodBoundaryHours.push(rule.endHour === 24 ? 0 : rule.endHour);
  }

  const windowMs = 24 * 60 * 60 * 1000;
  const has24hRepeat = zone.maxPrices.some(r => r.type === "per_24h_repeat");
  const breakdown: FeeBreakdown[] = [];
  let current = new Date(entry);

  while (current < exit) {
    const slot = getApplicableSlot(current, zone.slots);

    if (!slot) {
      const next = getNextSlotBoundary(current, zone.slots, periodBoundaryHours);
      current = next < exit ? next : exit;
      continue;
    }

    let nextBoundary = getNextSlotBoundary(current, zone.slots, periodBoundaryHours);
    // per_24h_repeat: 入庫から24時間ごとの境界でもセグメントを分割する
    if (has24hRepeat) {
      const elapsed = current.getTime() - entry.getTime();
      const nextWindowN = Math.floor(elapsed / windowMs) + 1;
      const next24h = new Date(entry.getTime() + nextWindowN * windowMs);
      if (next24h < nextBoundary) nextBoundary = next24h;
    }
    const segmentEnd = nextBoundary < exit ? nextBoundary : exit;
    const minutes = Math.round(
      (segmentEnd.getTime() - current.getTime()) / 60000
    );

    if (minutes > 0) {
      const subtotal = Math.ceil(minutes / slot.unitMinutes) * slot.unitPrice;
      const endLabel = slot.endHour === 24 ? "24:00" : `${slot.endHour}:00`;

      breakdown.push({
        dateKey: toDateKey(current),
        windowIndex: Math.floor((current.getTime() - entry.getTime()) / windowMs),
        slotStartHour: slot.startHour,
        slotEndHour: slot.endHour,
        segmentStartHour: current.getHours(),
        label: `${slot.startHour}:00〜${endLabel}`,
        minutes,
        unitPrice: slot.unitPrice,
        unitMinutes: slot.unitMinutes,
        subtotal,
      });
    }

    current = segmentEnd;
  }

  const rawTotal = breakdown.reduce((sum, b) => sum + b.subtotal, 0);
  let total = rawTotal;
  const maxPricesApplied: string[] = [];

  // ── フェーズ1: per_period キャップを適用 ─────────────────────────────
  // 対象スロットの区間ごとに集計してキャップ。
  // 複数の per_period ルールがあっても独立して適用する。
  let periodCoveredRaw = 0;  // per_period で対象となったセグメントの生コスト合計
  let periodCoveredCapped = 0; // per_period キャップ後のコスト合計

  for (const rule of zone.maxPrices) {
    if (rule.type !== "per_period") continue;
    const ps = rule.startHour ?? 0;
    const pe = rule.endHour ?? 24;

    const byPeriod = new Map<string, number>();
    for (const b of breakdown) {
      // スロット境界一致ではなく、セグメントの実際の時刻で判定する
      // （オールタイムスロット + 時間帯ごと最大料金 の場合に対応）
      const inPeriod = ps < pe
        ? b.segmentStartHour >= ps && b.segmentStartHour < pe
        : b.segmentStartHour >= ps || b.segmentStartHour < pe;
      if (!inPeriod) continue;
      const key = getPeriodInstanceKey(b, ps, pe);
      byPeriod.set(key, (byPeriod.get(key) ?? 0) + b.subtotal);
    }

    for (const [, cost] of byPeriod) {
      periodCoveredRaw += cost;
      periodCoveredCapped += Math.min(cost, rule.amount);
      if (cost > rule.amount) {
        const lbl = rule.label ?? `${ps}:00〜${pe === 24 ? "24:00" : pe + ":00"}最大`;
        if (!maxPricesApplied.includes(lbl)) maxPricesApplied.push(lbl);
      }
    }
  }

  // per_period で削減した分を total に反映
  total = total - periodCoveredRaw + periodCoveredCapped;

  // ── フェーズ2: per_day / per_24h_once / per_24h_repeat キャップを適用 ──
  // per_period を適用済みの total に対してさらにキャップをかける
  for (const rule of zone.maxPrices) {
    if (rule.type === "per_period") continue;
    const { amount, type } = rule;
    const lbl = rule.label;

    if (type === "per_24h_once") {
      if (total > amount) {
        maxPricesApplied.push(lbl ?? "24時間最大");
        total = amount;
      }
    } else if (type === "per_day") {
      // 日付（0時リセット）ごとに集計してキャップ
      // per_period 後の比率で近似する
      if (rawTotal === 0) continue;
      const byDay = new Map<string, number>();
      for (const b of breakdown) {
        byDay.set(b.dateKey, (byDay.get(b.dateKey) ?? 0) + b.subtotal);
      }
      let dayTotal = 0;
      let applied = false;
      for (const [, cost] of byDay) {
        // per_period 適用後の比率でスケーリング
        const adjustedCost = cost * (total / rawTotal);
        if (adjustedCost > amount) applied = true;
        dayTotal += Math.min(adjustedCost, amount);
      }
      if (dayTotal < total) {
        total = dayTotal;
        if (applied) maxPricesApplied.push(lbl ?? "当日最大");
      }
    } else if (type === "per_24h_repeat") {
      // 入庫から24時間ごとの窓でキャップ
      if (rawTotal === 0) continue;
      const byWindow = new Map<number, number>();
      for (const b of breakdown) {
        byWindow.set(b.windowIndex, (byWindow.get(b.windowIndex) ?? 0) + b.subtotal);
      }
      let windowTotal = 0;
      let applied = false;
      for (const [, cost] of byWindow) {
        const adjustedCost = cost * (total / rawTotal);
        if (adjustedCost > amount) applied = true;
        windowTotal += Math.min(adjustedCost, amount);
      }
      if (windowTotal < total) {
        total = windowTotal;
        if (applied) maxPricesApplied.push(lbl ?? "24時間ごと最大");
      }
    }
  }

  return {
    total: Math.round(total),
    breakdown,
    maxPricesApplied: [...new Set(maxPricesApplied)],
    rawTotal,
  };
}
