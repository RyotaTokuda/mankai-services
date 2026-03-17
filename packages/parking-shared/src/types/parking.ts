export type DayOfWeek = 0 | 1 | 2 | 3 | 4 | 5 | 6; // 0=日, 6=土

export type TimeSlot = {
  startHour: number;    // 0-23
  endHour: number;      // 1-24 (24 = 翌0時)
  unitMinutes: number;
  unitPrice: number;
  daysOfWeek?: DayOfWeek[]; // 未指定 = 全日
};

// per_day        : 当日0時リセット（「1日最大〇〇円」の典型）
// per_24h_once   : 入庫から24時間・1回限り・繰り返しなし
// per_24h_repeat : 入庫から24時間ごとに繰り返し適用
// per_period     : 特定時間帯（昼間・夜間など）の1区間ごとに上限適用
export type MaxPriceType = "per_day" | "per_24h_once" | "per_24h_repeat" | "per_period";

export type MaxPriceRule = {
  amount: number;
  type: MaxPriceType;
  label?: string;       // 表示ラベル（例: "昼間最大", "夜間最大"）
  startHour?: number;   // per_period のみ: 対象時間帯の開始（0-23）
  endHour?: number;     // per_period のみ: 対象時間帯の終了（1-24）
};

// 駐車枠の種別（普通車・軽自動車・バイクなど料金が異なる場合に使用）
export type ParkingZone = {
  name: string;         // 例: "普通車", "軽自動車", "全車種"
  slots: TimeSlot[];
  maxPrices: MaxPriceRule[];
};

export type NotePriority = "high" | "medium" | "low";

export type NoteCategory =
  | "max_price" // 最大料金の落とし穴
  | "vehicle"   // 車両制限（高さ・幅・重量）
  | "payment"   // 支払い方法
  | "reentry"   // 再入庫
  | "schedule"  // 曜日・時間帯の例外
  | "discount"; // サービス割引

export type ParkingNote = {
  priority: NotePriority;
  category: NoteCategory;
  text: string;
};

export type ParkingRules = {
  name: string;
  zones: ParkingZone[];
  notes: ParkingNote[];
};
