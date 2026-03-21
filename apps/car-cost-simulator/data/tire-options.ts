/**
 * タイヤサイズ・グレード別マスターデータ
 *
 * 代表的なタイヤサイズごとに、グレード別の4本セット価格と寿命を定義。
 * 年あたりのコスト = 4本セット価格 / 交換サイクル（年）
 *
 * グレード:
 *   economy  — 国産エコノミー・アジアンタイヤ（価格重視）
 *   standard — 国産スタンダード（バランス型、最も売れ筋）
 *   premium  — 国産プレミアム（静粛性・グリップ・長寿命）
 *
 * 更新日: 2026-03-21
 */

export interface TireGrade {
  grade: "economy" | "standard" | "premium";
  label: string;
  brandExample: string;
  price4set: number; // 4本セット工賃込み（円）
  lifeYears: number; // 交換サイクル（年）
  annualCost: number; // 年あたり按分（円）
  note: string;
}

export interface TireSize {
  size: string; // 例: "155/65R14"
  fitFor: string; // 対応車種の説明
  grades: TireGrade[];
}

export const TIRE_OPTIONS: TireSize[] = [
  {
    size: "155/65R14",
    fitFor: "軽自動車（N-BOX, タント, スペーシア, ハスラー等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "ダンロップ EC202L 等",
        price4set: 20000,
        lifeYears: 3,
        annualCost: 6700,
        note: "最安クラス。街乗り中心なら十分。雨の日のグリップはやや弱い。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ブリヂストン ネクストリー 等",
        price4set: 28000,
        lifeYears: 4,
        annualCost: 7000,
        note: "売れ筋。燃費性能と安全性のバランスが良い。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GR-Leggera 等",
        price4set: 40000,
        lifeYears: 4,
        annualCost: 10000,
        note: "静粛性が高く乗り心地が良い。長距離が多い人におすすめ。",
      },
    ],
  },
  {
    size: "175/70R14",
    fitFor: "コンパクトカー（ヤリス, フィット, ルーミー等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "ダンロップ EC202L 等",
        price4set: 24000,
        lifeYears: 3,
        annualCost: 8000,
        note: "コスパ重視。通勤・買い物メインなら十分。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ BluEarth-Es ES32 等",
        price4set: 36000,
        lifeYears: 4,
        annualCost: 9000,
        note: "低燃費タイヤの売れ筋。ウェットグリップも安心。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GR-XII 等",
        price4set: 52000,
        lifeYears: 5,
        annualCost: 10400,
        note: "静粛性・快適性が段違い。ロングライフで結果的にお得な場合も。",
      },
    ],
  },
  {
    size: "195/65R15",
    fitFor: "セダン・ワゴン（カローラ, インプレッサ等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "トーヨー SD-7 等",
        price4set: 32000,
        lifeYears: 3,
        annualCost: 10700,
        note: "価格重視。街乗りメインならOK。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ダンロップ エナセーブ EC204 等",
        price4set: 44000,
        lifeYears: 4,
        annualCost: 11000,
        note: "バランス型。通勤からドライブまで幅広く対応。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GR-XII 等",
        price4set: 68000,
        lifeYears: 5,
        annualCost: 13600,
        note: "高速走行時の安定性と静粛性が優秀。",
      },
    ],
  },
  {
    size: "205/60R16",
    fitFor: "ミニバン（ノア, セレナ, ステップワゴン等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "トーヨー トランパス mp7 等",
        price4set: 36000,
        lifeYears: 3,
        annualCost: 12000,
        note: "ミニバン用エコノミー。ふらつき抑制機能付きを選ぶのがおすすめ。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ BluEarth-RV RV03 等",
        price4set: 52000,
        lifeYears: 4,
        annualCost: 13000,
        note: "ミニバン専用設計。偏摩耗しにくく長持ち。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GRVIII 等",
        price4set: 76000,
        lifeYears: 5,
        annualCost: 15200,
        note: "ミニバン専用プレミアム。車内の静粛性が大幅に向上。",
      },
    ],
  },
  {
    size: "215/50R18",
    fitFor: "コンパクトSUV（ヤリスクロス, ヴェゼル等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "トーヨー プロクセス CF3 SUV 等",
        price4set: 44000,
        lifeYears: 3,
        annualCost: 14700,
        note: "SUV用エコノミー。18インチは安い選択肢が限られる。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ BluEarth-XT AE61 等",
        price4set: 60000,
        lifeYears: 4,
        annualCost: 15000,
        note: "SUV用低燃費タイヤ。オンロード重視。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ミシュラン プライマシー4+ 等",
        price4set: 84000,
        lifeYears: 5,
        annualCost: 16800,
        note: "ウェット性能・耐久性ともにトップクラス。",
      },
    ],
  },
  {
    size: "225/60R18",
    fitFor: "SUV（RAV4, ハリアー, CX-5等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "トーヨー プロクセス CF3 SUV 等",
        price4set: 52000,
        lifeYears: 3,
        annualCost: 17300,
        note: "SUV用で価格重視。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ダンロップ グラントレック PT5 等",
        price4set: 72000,
        lifeYears: 4,
        annualCost: 18000,
        note: "SUV専用設計。耐摩耗性が良い。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ミシュラン プライマシー SUV+ 等",
        price4set: 100000,
        lifeYears: 5,
        annualCost: 20000,
        note: "長寿命・低騒音。高速でのロードノイズが大幅に低減。",
      },
    ],
  },
  {
    size: "225/55R19",
    fitFor: "プレミアムSUV（ハリアー上位, アルファード等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー",
        brandExample: "トーヨー プロクセス CF3 SUV 等",
        price4set: 60000,
        lifeYears: 3,
        annualCost: 20000,
        note: "19インチはエコノミーでもそれなりの価格。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ ADVAN dB V553 等",
        price4set: 88000,
        lifeYears: 4,
        annualCost: 22000,
        note: "静粛性重視のスタンダード。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ミシュラン e・プライマシー 等",
        price4set: 120000,
        lifeYears: 5,
        annualCost: 24000,
        note: "最上級の乗り心地。電動車・HV対応の低転がり抵抗。",
      },
    ],
  },
  {
    size: "175/80R16",
    fitFor: "ジムニー",
    grades: [
      {
        grade: "economy",
        label: "エコノミー（オンロード）",
        brandExample: "ダンロップ グラントレック AT5 等",
        price4set: 36000,
        lifeYears: 3,
        annualCost: 12000,
        note: "オンロード寄りのSUVタイヤ。街乗り中心ならこれで十分。",
      },
      {
        grade: "standard",
        label: "スタンダード（A/T）",
        brandExample: "ヨコハマ ジオランダー A/T G015 等",
        price4set: 48000,
        lifeYears: 4,
        annualCost: 12000,
        note: "オン・オフ両用のオールテレーン。ジムニーの定番。",
      },
      {
        grade: "premium",
        label: "プレミアム（M/T）",
        brandExample: "トーヨー オープンカントリー M/T 等",
        price4set: 64000,
        lifeYears: 3,
        annualCost: 21300,
        note: "本格オフロード用マッドテレーン。ロードノイズ大、寿命は短め。",
      },
    ],
  },
  {
    size: "265/65R18",
    fitFor: "大型SUV（ランドクルーザー等）",
    grades: [
      {
        grade: "economy",
        label: "エコノミー（H/T）",
        brandExample: "トーヨー プロクセス CF3 SUV 等",
        price4set: 80000,
        lifeYears: 3,
        annualCost: 26700,
        note: "大型SUVはタイヤ単価が高い。オンロード用。",
      },
      {
        grade: "standard",
        label: "スタンダード（A/T）",
        brandExample: "ヨコハマ ジオランダー A/T G015 等",
        price4set: 120000,
        lifeYears: 4,
        annualCost: 30000,
        note: "オン・オフ兼用。ランクルの標準的な選択肢。",
      },
      {
        grade: "premium",
        label: "プレミアム（A/T）",
        brandExample: "ブリヂストン デューラー A/T 002 等",
        price4set: 160000,
        lifeYears: 5,
        annualCost: 32000,
        note: "ロングライフ＆高グリップ。高速安定性も良い。",
      },
    ],
  },
];

/** 車両価格からおすすめのタイヤサイズインデックスを返す */
export function suggestTireSizeIndex(vehiclePrice: number): number {
  if (vehiclePrice <= 1600000) return 0; // 155/65R14 軽
  if (vehiclePrice <= 2200000) return 1; // 175/70R14 コンパクト
  if (vehiclePrice <= 3000000) return 2; // 195/65R15 セダン
  if (vehiclePrice <= 3800000) return 3; // 205/60R16 ミニバン
  if (vehiclePrice <= 5000000) return 5; // 225/60R18 SUV
  return 6; // 225/55R19 プレミアム
}
