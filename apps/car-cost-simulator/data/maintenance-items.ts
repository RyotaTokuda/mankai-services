/**
 * 消耗品・整備項目マスターデータ
 *
 * 各項目の費用目安と交換頻度。
 * category:
 *   "regular"  — 定期的に発生する小額の費用（毎月〜半年）
 *   "periodic" — 数年に1回まとめて発生する費用
 *
 * 更新日: 2026-03-21
 */

export interface MaintenanceItem {
  key: string;
  label: string;
  category: "regular" | "periodic";
  /** 1回あたりの費用（円） */
  costPerTime: number;
  /** 交換間隔の説明 */
  intervalLabel: string;
  /** 年あたり換算の費用（円） */
  annualCost: number;
  /** 補足説明 */
  note: string;
}

/** 普通車（1.5L コンパクトカー）の標準的な消耗品 */
export const MAINTENANCE_ITEMS_COMPACT: MaintenanceItem[] = [
  // ── 定期的（小額・こまめ） ──
  {
    key: "engineOil",
    label: "エンジンオイル交換",
    category: "regular",
    costPerTime: 5000,
    intervalLabel: "半年 or 5,000kmの早い方（年2回〜）",
    annualCost: 10000,
    note: "半年または走行5,000kmのどちらか早い方で交換。年1万km走行なら年2回、年2万kmなら年4回。ディーラーで4〜6千円、カー用品店で3〜5千円。",
  },
  {
    key: "oilFilter",
    label: "オイルフィルター",
    category: "regular",
    costPerTime: 1500,
    intervalLabel: "オイル交換2回に1回（年1回）",
    annualCost: 1500,
    note: "オイル交換と同時に交換。工賃込みで1,000〜2,000円。",
  },
  {
    key: "wiperRubber",
    label: "ワイパーゴム",
    category: "regular",
    costPerTime: 1500,
    intervalLabel: "半年に1回（年2回）",
    annualCost: 3000,
    note: "フロント2本+リア1本のゴムのみ交換。1回1,000〜2,000円。半年で劣化するため定期交換推奨。",
  },
  {
    key: "wiperBlade",
    label: "ワイパーブレード",
    category: "regular",
    costPerTime: 3000,
    intervalLabel: "年1回",
    annualCost: 3000,
    note: "フロント2本+リア1本のブレードごと交換。ゴム交換では改善しないガタつきが出たら交換。2,000〜5,000円。",
  },
  {
    key: "washerFluid",
    label: "ウォッシャー液",
    category: "regular",
    costPerTime: 300,
    intervalLabel: "年2〜3回補充",
    annualCost: 700,
    note: "2L入りで200〜500円。なくなったら補充。",
  },
  // ── 数年に1回（まとまった出費） ──
  {
    key: "battery",
    label: "バッテリー交換",
    category: "periodic",
    costPerTime: 15000,
    intervalLabel: "3〜4年に1回",
    annualCost: 4300,
    note: "普通車で10,000〜25,000円（工賃込）。アイドリングストップ車は専用品で割高。突然のバッテリー上がりに注意。",
  },
  {
    key: "brakePad",
    label: "ブレーキパッド交換",
    category: "periodic",
    costPerTime: 20000,
    intervalLabel: "3〜5万kmごと（3〜4年）",
    annualCost: 5700,
    note: "フロント左右で15,000〜30,000円（工賃込）。キーキー音が出たら即交換。ディスクローターも同時交換だと+20,000円。",
  },
  {
    key: "airFilter",
    label: "エアクリーナー",
    category: "periodic",
    costPerTime: 3000,
    intervalLabel: "2〜3年に1回",
    annualCost: 1200,
    note: "2,000〜4,000円。汚れると燃費が悪化するので定期交換推奨。",
  },
  {
    key: "acFilter",
    label: "エアコンフィルター",
    category: "periodic",
    costPerTime: 3000,
    intervalLabel: "年1回",
    annualCost: 3000,
    note: "2,000〜4,000円。花粉・PM2.5対策のため年1回交換推奨。自分で交換すれば1,000円台。",
  },
  {
    key: "coolant",
    label: "クーラント（冷却水）",
    category: "periodic",
    costPerTime: 5000,
    intervalLabel: "2〜3年に1回（車検時）",
    annualCost: 2000,
    note: "3,000〜7,000円（工賃込）。車検時に交換するのが一般的。",
  },
  {
    key: "brakeFluid",
    label: "ブレーキフルード",
    category: "periodic",
    costPerTime: 5000,
    intervalLabel: "2年に1回（車検時）",
    annualCost: 2500,
    note: "3,000〜6,000円。吸湿して劣化するので車検ごとの交換が推奨。",
  },
  {
    key: "sparkPlug",
    label: "スパークプラグ",
    category: "periodic",
    costPerTime: 8000,
    intervalLabel: "4〜5年に1回",
    annualCost: 1800,
    note: "4本で5,000〜12,000円（工賃込）。イリジウムプラグなら10万km持つ車種も。",
  },
  {
    key: "atfCvt",
    label: "ATF / CVTフルード",
    category: "periodic",
    costPerTime: 10000,
    intervalLabel: "4〜5年に1回",
    annualCost: 2200,
    note: "8,000〜15,000円。メーカー推奨交換時期を確認。無交換指定の車種もある。",
  },
];

/** 軽自動車の消耗品（普通車より若干安い） */
export const MAINTENANCE_ITEMS_KEI: MaintenanceItem[] = [
  {
    key: "engineOil",
    label: "エンジンオイル交換",
    category: "regular",
    costPerTime: 3500,
    intervalLabel: "半年 or 5,000kmの早い方（年2回〜）",
    annualCost: 7000,
    note: "半年または走行5,000kmのどちらか早い方で交換。軽自動車はオイル量が少なく3〜5千円。ターボ車はこまめな交換推奨。",
  },
  {
    key: "oilFilter",
    label: "オイルフィルター",
    category: "regular",
    costPerTime: 1200,
    intervalLabel: "年1回",
    annualCost: 1200,
    note: "工賃込みで1,000〜1,500円。",
  },
  {
    key: "wiperRubber",
    label: "ワイパーゴム",
    category: "regular",
    costPerTime: 1200,
    intervalLabel: "半年に1回（年2回）",
    annualCost: 2400,
    note: "フロント2本+リア1本のゴムのみ交換。軽は小さいので1回800〜1,500円。",
  },
  {
    key: "wiperBlade",
    label: "ワイパーブレード",
    category: "regular",
    costPerTime: 2500,
    intervalLabel: "年1回",
    annualCost: 2500,
    note: "ブレードごと交換。1,500〜3,500円。",
  },
  {
    key: "washerFluid",
    label: "ウォッシャー液",
    category: "regular",
    costPerTime: 300,
    intervalLabel: "年2〜3回補充",
    annualCost: 700,
    note: "普通車と同じ。",
  },
  {
    key: "battery",
    label: "バッテリー交換",
    category: "periodic",
    costPerTime: 10000,
    intervalLabel: "3〜4年に1回",
    annualCost: 2900,
    note: "軽は小型バッテリーで7,000〜15,000円。アイドリングストップ車は専用品で割高。",
  },
  {
    key: "brakePad",
    label: "ブレーキパッド交換",
    category: "periodic",
    costPerTime: 15000,
    intervalLabel: "3〜5万kmごと",
    annualCost: 4300,
    note: "軽は10,000〜20,000円（工賃込）。",
  },
  {
    key: "airFilter",
    label: "エアクリーナー",
    category: "periodic",
    costPerTime: 2500,
    intervalLabel: "2〜3年に1回",
    annualCost: 1000,
    note: "1,500〜3,000円。",
  },
  {
    key: "acFilter",
    label: "エアコンフィルター",
    category: "periodic",
    costPerTime: 2500,
    intervalLabel: "年1回",
    annualCost: 2500,
    note: "1,500〜3,000円。",
  },
  {
    key: "coolant",
    label: "クーラント（冷却水）",
    category: "periodic",
    costPerTime: 4000,
    intervalLabel: "2〜3年に1回",
    annualCost: 1600,
    note: "車検時に交換が一般的。",
  },
  {
    key: "brakeFluid",
    label: "ブレーキフルード",
    category: "periodic",
    costPerTime: 4000,
    intervalLabel: "2年に1回",
    annualCost: 2000,
    note: "車検ごとの交換が推奨。",
  },
  {
    key: "sparkPlug",
    label: "スパークプラグ",
    category: "periodic",
    costPerTime: 5000,
    intervalLabel: "4〜5年に1回",
    annualCost: 1100,
    note: "3本で3,000〜7,000円。",
  },
  {
    key: "cvtFluid",
    label: "CVTフルード",
    category: "periodic",
    costPerTime: 8000,
    intervalLabel: "4〜5年に1回",
    annualCost: 1800,
    note: "6,000〜10,000円。",
  },
];

/** 大型車・高級車の消耗品 */
export const MAINTENANCE_ITEMS_LARGE: MaintenanceItem[] = [
  {
    key: "engineOil",
    label: "エンジンオイル交換",
    category: "regular",
    costPerTime: 8000,
    intervalLabel: "半年 or 5,000kmの早い方（年2回〜）",
    annualCost: 16000,
    note: "半年または走行5,000kmのどちらか早い方。オイル量が多く6〜12千円。高性能オイル指定の車種はさらに高額。",
  },
  {
    key: "oilFilter",
    label: "オイルフィルター",
    category: "regular",
    costPerTime: 2000,
    intervalLabel: "年1回",
    annualCost: 2000,
    note: "工賃込みで1,500〜3,000円。",
  },
  {
    key: "wiperRubber",
    label: "ワイパーゴム",
    category: "regular",
    costPerTime: 2000,
    intervalLabel: "半年に1回（年2回）",
    annualCost: 4000,
    note: "フロント2本+リア1本のゴムのみ交換。大型ワイパーで1回1,500〜2,500円。",
  },
  {
    key: "wiperBlade",
    label: "ワイパーブレード",
    category: "regular",
    costPerTime: 4000,
    intervalLabel: "年1回",
    annualCost: 4000,
    note: "ブレードごと交換。大型で3,000〜5,000円。",
  },
  {
    key: "washerFluid",
    label: "ウォッシャー液",
    category: "regular",
    costPerTime: 300,
    intervalLabel: "年2〜3回",
    annualCost: 700,
    note: "普通車と同じ。",
  },
  {
    key: "battery",
    label: "バッテリー交換",
    category: "periodic",
    costPerTime: 25000,
    intervalLabel: "3〜4年に1回",
    annualCost: 7100,
    note: "大容量バッテリーで20,000〜40,000円。HV車は補機バッテリーのみ（駆動用は10年以上持つ）。",
  },
  {
    key: "brakePad",
    label: "ブレーキパッド交換",
    category: "periodic",
    costPerTime: 35000,
    intervalLabel: "3〜5万kmごと",
    annualCost: 10000,
    note: "大型車は25,000〜50,000円（工賃込）。ローター同時交換で+30,000円。",
  },
  {
    key: "airFilter",
    label: "エアクリーナー",
    category: "periodic",
    costPerTime: 4000,
    intervalLabel: "2〜3年に1回",
    annualCost: 1600,
    note: "3,000〜6,000円。",
  },
  {
    key: "acFilter",
    label: "エアコンフィルター",
    category: "periodic",
    costPerTime: 4000,
    intervalLabel: "年1回",
    annualCost: 4000,
    note: "3,000〜5,000円。大型車はフィルターが大きい。",
  },
  {
    key: "coolant",
    label: "クーラント（冷却水）",
    category: "periodic",
    costPerTime: 7000,
    intervalLabel: "2〜3年に1回",
    annualCost: 2800,
    note: "量が多く5,000〜10,000円。",
  },
  {
    key: "brakeFluid",
    label: "ブレーキフルード",
    category: "periodic",
    costPerTime: 6000,
    intervalLabel: "2年に1回",
    annualCost: 3000,
    note: "4,000〜8,000円。",
  },
  {
    key: "sparkPlug",
    label: "スパークプラグ",
    category: "periodic",
    costPerTime: 15000,
    intervalLabel: "4〜5年に1回",
    annualCost: 3400,
    note: "6気筒以上で8,000〜20,000円。",
  },
  {
    key: "atf",
    label: "ATF / CVTフルード",
    category: "periodic",
    costPerTime: 15000,
    intervalLabel: "4〜5年に1回",
    annualCost: 3400,
    note: "量が多く10,000〜20,000円。",
  },
];

export function getTotalAnnualMaintenance(items: MaintenanceItem[]): number {
  return items.reduce((sum, item) => sum + item.annualCost, 0);
}
