/**
 * 自動車税（種別割）マスターデータ
 *
 * 2019年10月1日以降に新車登録した自家用乗用車の税額
 * 軽自動車税は自家用乗用の場合、一律 10,800円
 *
 * 参考:
 * - https://www.tax.metro.tokyo.lg.jp/kazei/automobiles/shubetsu
 * - https://www.sonysonpo.co.jp/auto/guide/agde093.html
 */

/** 排気量（cc）の上限 → 税額（円/年） */
const AUTO_TAX_TABLE: [number, number][] = [
  [660, 10800], // 軽自動車
  [1000, 25000],
  [1500, 30500],
  [2000, 36000],
  [2500, 43500],
  [3000, 50000],
  [3500, 57000],
  [4000, 65500],
  [4500, 75500],
  [6000, 87000],
  [Infinity, 110000],
];

/** 排気量（cc）から自動車税額を返す */
export function getAutoTax(displacementCc: number): number {
  for (const [maxCc, tax] of AUTO_TAX_TABLE) {
    if (displacementCc <= maxCc) return tax;
  }
  return 110000;
}
