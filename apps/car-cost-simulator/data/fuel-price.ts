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
  ev: 31, // 電気（円/kWh → 電費km/kWhで換算するため、ガソリン換算値を使用）
  // EV換算: 電気代31円/kWh ÷ 電費6km/kWh = 約5.2円/km
  // ガソリン換算: 燃費=33km/L, 単価=175円/L として同等コストで表現
} as const;

export const DEFAULT_FUEL_PRICE = FUEL_PRICES.regular;
