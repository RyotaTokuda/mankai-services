/**
 * タイヤサイズ・グレード別マスターデータ
 *
 * タイヤ館・オートバックス等の実店舗での工賃込み（組替+バランス+廃タイヤ処理）
 * 価格帯で設定。ネット最安値ではなく「店舗で普通に買った場合」の目安。
 *
 * 工賃目安: 脱着+組替+バランス 1本あたり2,000〜3,500円、廃タイヤ処理330円/本
 * → 4本で約10,000〜16,000円の工賃が含まれている
 *
 * 更新日: 2026-03-21
 */

export interface TireGrade {
  grade: "economy" | "standard" | "premium";
  label: string;
  brandExample: string;
  price4set: number;
  lifeYears: number;
  annualCost: number;
  note: string;
}

export interface TireSize {
  size: string;
  fitFor: string;
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
        brandExample: "ダンロップ エナセーブ EC204 等",
        price4set: 32000,
        lifeYears: 3,
        annualCost: 10700,
        note: "店舗の定番品。街乗り中心なら十分な性能。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ブリヂストン NEWNO 等",
        price4set: 42000,
        lifeYears: 4,
        annualCost: 10500,
        note: "タイヤ館/オートバックスの売れ筋。燃費と安全性のバランスが良い。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GR-Leggera 等",
        price4set: 56000,
        lifeYears: 5,
        annualCost: 11200,
        note: "静粛性が段違い。長距離が多い人は長寿命で結果的にお得。",
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
        brandExample: "ダンロップ エナセーブ EC204 等",
        price4set: 38000,
        lifeYears: 3,
        annualCost: 12700,
        note: "コスパ重視。通勤・買い物メインなら十分。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ BluEarth-Es ES32 等",
        price4set: 50000,
        lifeYears: 4,
        annualCost: 12500,
        note: "低燃費タイヤの売れ筋。ウェットグリップも安心。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GR-XII 等",
        price4set: 68000,
        lifeYears: 5,
        annualCost: 13600,
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
        price4set: 46000,
        lifeYears: 3,
        annualCost: 15300,
        note: "店舗で手軽に買えるエントリーモデル。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ダンロップ エナセーブ EC204 等",
        price4set: 60000,
        lifeYears: 4,
        annualCost: 15000,
        note: "バランス型。通勤からドライブまで幅広く対応。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GR-XII 等",
        price4set: 84000,
        lifeYears: 5,
        annualCost: 16800,
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
        price4set: 52000,
        lifeYears: 3,
        annualCost: 17300,
        note: "ミニバン用エコノミー。ふらつき抑制機能付きを選ぶのがおすすめ。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ BluEarth-RV RV03 等",
        price4set: 68000,
        lifeYears: 4,
        annualCost: 17000,
        note: "ミニバン専用設計。偏摩耗しにくく長持ち。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ブリヂストン レグノ GRVIII 等",
        price4set: 92000,
        lifeYears: 5,
        annualCost: 18400,
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
        brandExample: "クムホ ソルウス HS63 等",
        price4set: 60000,
        lifeYears: 3,
        annualCost: 20000,
        note: "18インチは安い選択肢が限られる。アジアンタイヤが有力。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ BluEarth-XT AE61 等",
        price4set: 80000,
        lifeYears: 4,
        annualCost: 20000,
        note: "SUV用低燃費タイヤ。オンロード重視。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ミシュラン プライマシー4+ 等",
        price4set: 108000,
        lifeYears: 5,
        annualCost: 21600,
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
        brandExample: "クムホ クルーゼン HP71 等",
        price4set: 64000,
        lifeYears: 3,
        annualCost: 21300,
        note: "SUV用で価格重視。アジアンブランドが中心。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ダンロップ グラントレック PT5 等",
        price4set: 96000,
        lifeYears: 4,
        annualCost: 24000,
        note: "SUV専用設計。耐摩耗性が良い。1本あたり約24,000円。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ミシュラン パイロットスポーツ4 SUV 等",
        price4set: 140000,
        lifeYears: 5,
        annualCost: 28000,
        note: "1本あたり約32,000円。長寿命・低騒音でハイグリップ。",
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
        brandExample: "ピレリ パワジー 等",
        price4set: 80000,
        lifeYears: 3,
        annualCost: 26700,
        note: "19インチはエコノミーでもそれなりの価格。",
      },
      {
        grade: "standard",
        label: "スタンダード",
        brandExample: "ヨコハマ ADVAN dB V553 等",
        price4set: 112000,
        lifeYears: 4,
        annualCost: 28000,
        note: "静粛性重視のスタンダード。",
      },
      {
        grade: "premium",
        label: "プレミアム",
        brandExample: "ミシュラン e・プライマシー 等",
        price4set: 148000,
        lifeYears: 5,
        annualCost: 29600,
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
        price4set: 48000,
        lifeYears: 3,
        annualCost: 16000,
        note: "オンロード寄りのSUVタイヤ。街乗り中心ならこれで十分。",
      },
      {
        grade: "standard",
        label: "スタンダード（A/T）",
        brandExample: "ヨコハマ ジオランダー A/T G015 等",
        price4set: 64000,
        lifeYears: 4,
        annualCost: 16000,
        note: "オン・オフ両用のオールテレーン。ジムニーの定番。",
      },
      {
        grade: "premium",
        label: "プレミアム（M/T）",
        brandExample: "トーヨー オープンカントリー M/T 等",
        price4set: 80000,
        lifeYears: 3,
        annualCost: 26700,
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
        price4set: 100000,
        lifeYears: 3,
        annualCost: 33300,
        note: "大型SUVはタイヤ単価が高い。1本あたり約25,000円。",
      },
      {
        grade: "standard",
        label: "スタンダード（A/T）",
        brandExample: "ヨコハマ ジオランダー A/T G015 等",
        price4set: 148000,
        lifeYears: 4,
        annualCost: 37000,
        note: "オン・オフ兼用。ランクルの標準的な選択肢。1本あたり約37,000円。",
      },
      {
        grade: "premium",
        label: "プレミアム（A/T）",
        brandExample: "ブリヂストン デューラー A/T 002 等",
        price4set: 192000,
        lifeYears: 5,
        annualCost: 38400,
        note: "1本あたり約48,000円。ロングライフ＆高グリップ。",
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
