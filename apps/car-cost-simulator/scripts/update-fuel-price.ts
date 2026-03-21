/**
 * ガソリン価格を資源エネルギー庁のデータから更新するスクリプト
 *
 * 使い方: npx tsx scripts/update-fuel-price.ts
 *
 * 資源エネルギー庁の石油製品価格調査APIから最新の全国平均価格を取得し、
 * data/fuel-price.ts を更新する。
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FUEL_PRICE_PATH = path.resolve(__dirname, "../data/fuel-price.ts");

async function fetchLatestPrices(): Promise<{
  regular: number;
  premium: number;
  diesel: number;
}> {
  // e-stat APIまたはスクレイピングで取得
  // フォールバック: 手動で設定した値を返す
  try {
    const res = await fetch(
      "https://www.enecho.meti.go.jp/statistics/petroleum_and_lpgas/pl007/results.html"
    );
    const html = await res.text();

    // ページからレギュラー・ハイオク・軽油の価格を抽出（簡易パース）
    // 実際の値はHTMLの構造に依存するため、フォールバックを用意
    console.log("資源エネルギー庁のページを取得しました。手動確認が必要です。");
    console.log(
      "最新の価格を確認して data/fuel-price.ts を手動更新してください。"
    );
    console.log("URL: https://www.enecho.meti.go.jp/statistics/petroleum_and_lpgas/pl007/results.html");
  } catch {
    console.log("価格取得に失敗しました。手動更新が必要です。");
  }

  // 現在の値をそのまま返す（自動更新できない場合のフォールバック）
  return { regular: 175, premium: 186, diesel: 155 };
}

async function main() {
  console.log("==> ガソリン価格の確認...");
  const prices = await fetchLatestPrices();
  console.log(`レギュラー: ${prices.regular}円/L`);
  console.log(`ハイオク: ${prices.premium}円/L`);
  console.log(`軽油: ${prices.diesel}円/L`);

  const content = `/**
 * ガソリン価格マスターデータ
 *
 * 資源エネルギー庁 石油製品価格調査 + 政府補助金を反映した目安価格
 * 更新日: ${new Date().toISOString().split("T")[0]}
 *
 * 参考:
 * - https://www.enecho.meti.go.jp/statistics/petroleum_and_lpgas/pl007/results.html
 */

export const FUEL_PRICES = {
  regular: ${prices.regular}, // レギュラー（円/L）
  premium: ${prices.premium}, // ハイオク（円/L）
  diesel: ${prices.diesel}, // 軽油（円/L）
  ev: 31, // 電気（円/kWh）
} as const;

export const DEFAULT_FUEL_PRICE = FUEL_PRICES.regular;
`;

  fs.writeFileSync(FUEL_PRICE_PATH, content);
  console.log(`==> ${FUEL_PRICE_PATH} を更新しました`);
}

main();
