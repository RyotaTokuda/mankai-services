/**
 * master/car-models.csv → data/car-models.ts に変換するスクリプト
 *
 * 使い方:
 *   npx tsx scripts/build-car-models.ts
 *
 * CSVを編集したら、このスクリプトを実行して data/car-models.ts を再生成する
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const CSV_PATH = path.join(ROOT, "master", "car-models.csv");
const OUTPUT_PATH = path.join(ROOT, "data", "car-models.ts");

interface RawRow {
  category: string;
  category_icon: string;
  name: string;
  maker: string;
  displacement_cc: number;
  fuel_type: string;
  vehicle_price: number;
  interest_rate: number;
  loan_years: number;
  parking_fee: number;
  insurance_fee: number;
  auto_tax: number;
  inspection_fee: number;
  fuel_efficiency: number;
  annual_mileage: number;
  tire_fee: number;
  maintenance_fee: number;
  resale_rate: number;
}

function parseCSV(text: string): RawRow[] {
  const lines = text.trim().split("\n");
  const headers = lines[0].split(",");
  return lines.slice(1).map((line) => {
    const values = line.split(",");
    const row: Record<string, string | number> = {};
    headers.forEach((h, i) => {
      const v = values[i]?.trim() ?? "";
      // 数値列
      if (
        [
          "displacement_cc",
          "vehicle_price",
          "interest_rate",
          "loan_years",
          "parking_fee",
          "insurance_fee",
          "auto_tax",
          "inspection_fee",
          "fuel_efficiency",
          "annual_mileage",
          "tire_fee",
          "maintenance_fee",
          "resale_rate",
        ].includes(h)
      ) {
        row[h] = Number(v) || 0;
      } else {
        row[h] = v;
      }
    });
    return row as unknown as RawRow;
  });
}

function fuelPriceRef(fuelType: string): string {
  switch (fuelType) {
    case "premium":
      return "FUEL_PRICES.premium";
    case "diesel":
      return "FUEL_PRICES.diesel";
    case "ev":
      return "DEFAULT_FUEL_PRICE";
    default:
      return "DEFAULT_FUEL_PRICE";
  }
}

function generateTS(rows: RawRow[]): string {
  // カテゴリごとにグルーピング
  const categories = new Map<
    string,
    { icon: string; models: RawRow[] }
  >();
  for (const row of rows) {
    if (!categories.has(row.category)) {
      categories.set(row.category, {
        icon: row.category_icon,
        models: [],
      });
    }
    categories.get(row.category)!.models.push(row);
  }

  let code = `/**
 * 人気車種マスターデータ（自動生成）
 *
 * このファイルは scripts/build-car-models.ts によって
 * master/car-models.csv から自動生成されています。
 * 直接編集しないでください。
 *
 * 車種を追加・編集する場合は master/car-models.csv を編集し、
 *   npx tsx scripts/build-car-models.ts
 * を実行してください。
 *
 * 生成日: ${new Date().toISOString().split("T")[0]}
 */

import type { CarScenario } from "../lib/types";
import { DEFAULT_FUEL_PRICE, FUEL_PRICES } from "./fuel-price";

export interface CarModel {
  name: string;
  maker: string;
  category: string;
  displacementCc: number;
  fuelType: "regular" | "premium" | "diesel" | "ev";
  values: Omit<CarScenario, "id">;
}

export interface CarModelCategory {
  name: string;
  icon: string;
  models: CarModel[];
}

export const CAR_MODEL_CATEGORIES: CarModelCategory[] = [\n`;

  for (const [catName, cat] of categories) {
    code += `  {\n`;
    code += `    name: ${JSON.stringify(catName)},\n`;
    code += `    icon: ${JSON.stringify(cat.icon)},\n`;
    code += `    models: [\n`;

    for (const m of cat.models) {
      const displayName = `${m.name} (${m.maker})`;
      code += `      {\n`;
      code += `        name: ${JSON.stringify(m.name)},\n`;
      code += `        maker: ${JSON.stringify(m.maker)},\n`;
      code += `        category: ${JSON.stringify(catName)},\n`;
      code += `        displacementCc: ${m.displacement_cc},\n`;
      code += `        fuelType: ${JSON.stringify(m.fuel_type)},\n`;
      code += `        values: {\n`;
      code += `          name: ${JSON.stringify(displayName)},\n`;
      code += `          vehiclePrice: ${m.vehicle_price},\n`;
      code += `          downPayment: 0,\n`;
      code += `          interestRate: ${m.interest_rate},\n`;
      code += `          loanYears: ${m.loan_years},\n`;
      code += `          parkingFee: ${m.parking_fee},\n`;
      code += `          insuranceFee: ${m.insurance_fee},\n`;
      code += `          autoTax: ${m.auto_tax},\n`;
      code += `          inspectionFee: ${m.inspection_fee},\n`;
      code += `          fuelEfficiency: ${m.fuel_efficiency},\n`;
      code += `          fuelPrice: ${fuelPriceRef(m.fuel_type)},\n`;
      code += `          annualMileage: ${m.annual_mileage},\n`;
      code += `          tireFee: ${m.tire_fee},\n`;
      code += `          maintenanceFee: ${m.maintenance_fee},\n`;
      code += `          resaleRate: ${m.resale_rate || 40},\n`;
      code += `        },\n`;
      code += `      },\n`;
    }

    code += `    ],\n`;
    code += `  },\n`;
  }

  code += `];\n`;
  return code;
}

// 実行
const csv = fs.readFileSync(CSV_PATH, "utf-8");
const rows = parseCSV(csv);
const ts = generateTS(rows);
fs.writeFileSync(OUTPUT_PATH, ts);
console.log(
  `Generated ${OUTPUT_PATH} (${rows.length} models, ${new Set(rows.map((r) => r.category)).size} categories)`
);
