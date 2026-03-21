/**
 * ガソリン価格マスターデータ
 *
 * 資源エネルギー庁 石油製品価格調査 + 政府補助金を反映した目安価格
 * 更新日: 2026-03-21（補助金再開後の目安値）
 *
 * 参考:
 * - https://www.enecho.meti.go.jp/statistics/petroleum_and_lpgas/pl007/results.html
 * - https://nenryo-teigakuhikisage.go.jp/
 */

export const FUEL_PRICES = {
  regular: 175, // レギュラー（円/L）
  premium: 186, // ハイオク（円/L）
  diesel: 155, // 軽油（円/L）
} as const;

export const DEFAULT_FUEL_PRICE = FUEL_PRICES.regular;
