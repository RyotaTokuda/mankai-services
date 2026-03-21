/**
 * 人気車種マスターデータ
 *
 * 2022〜2024年の国内販売台数上位を中心に、カテゴリ別に整理
 * 車両価格は新車の売れ筋グレードの乗り出し価格目安（税込）
 *
 * 各値の根拠:
 * - 車両価格: メーカー公式サイトの売れ筋グレード + 諸費用
 * - 自動車税: data/auto-tax.ts の排気量別テーブルに準拠
 * - 車検費用: 法定費用 + 整備費用の目安（ディーラー車検想定）
 * - タイヤ: 純正サイズの国産メーカー品を4〜5年で交換、年あたり按分
 * - 消耗品: オイル交換(年2回)+バッテリー+ワイパー+ブレーキパッド等の年按分
 * - 燃費: e燃費等の実燃費データを参考（カタログ値の70〜80%）
 * - ガソリン単価: data/fuel-price.ts の値に準拠
 *
 * 更新日: 2026-03-21
 */

import type { CarScenario } from "../lib/types";
import { DEFAULT_FUEL_PRICE, FUEL_PRICES } from "./fuel-price";

export interface CarModel {
  name: string;
  maker: string;
  category: string;
  displacementCc: number; // 排気量（参考情報）
  fuelType: "regular" | "premium" | "diesel";
  values: Omit<CarScenario, "id">;
}

export interface CarModelCategory {
  name: string;
  icon: string;
  models: CarModel[];
}

export const CAR_MODEL_CATEGORIES: CarModelCategory[] = [
  {
    name: "軽自動車",
    icon: "🚙",
    models: [
      {
        name: "N-BOX",
        maker: "ホンダ",
        category: "軽自動車",
        displacementCc: 658,
        fuelType: "regular",
        values: {
          name: "N-BOX (ホンダ)",
          vehiclePrice: 1850000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 8000,
          insuranceFee: 4000,
          autoTax: 10800, // 軽自動車一律
          inspectionFee: 55000, // 法定費用27,000+整備28,000
          fuelEfficiency: 21,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 8000,
          tireFee: 7000, // 155/65R14 4本28,000円/4年
          maintenanceFee: 18000,
        },
      },
      {
        name: "タント",
        maker: "ダイハツ",
        category: "軽自動車",
        displacementCc: 658,
        fuelType: "regular",
        values: {
          name: "タント (ダイハツ)",
          vehiclePrice: 1650000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 8000,
          insuranceFee: 4000,
          autoTax: 10800,
          inspectionFee: 55000,
          fuelEfficiency: 22,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 8000,
          tireFee: 7000,
          maintenanceFee: 18000,
        },
      },
      {
        name: "スペーシア",
        maker: "スズキ",
        category: "軽自動車",
        displacementCc: 658,
        fuelType: "regular",
        values: {
          name: "スペーシア (スズキ)",
          vehiclePrice: 1600000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 8000,
          insuranceFee: 4000,
          autoTax: 10800,
          inspectionFee: 55000,
          fuelEfficiency: 23,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 8000,
          tireFee: 7000,
          maintenanceFee: 18000,
        },
      },
      {
        name: "ハスラー",
        maker: "スズキ",
        category: "軽自動車",
        displacementCc: 658,
        fuelType: "regular",
        values: {
          name: "ハスラー (スズキ)",
          vehiclePrice: 1550000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 8000,
          insuranceFee: 4000,
          autoTax: 10800,
          inspectionFee: 55000,
          fuelEfficiency: 22,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 8000,
          tireFee: 7000,
          maintenanceFee: 18000,
        },
      },
      {
        name: "ジムニー",
        maker: "スズキ",
        category: "軽自動車",
        displacementCc: 658,
        fuelType: "regular",
        values: {
          name: "ジムニー (スズキ)",
          vehiclePrice: 1900000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 8000,
          insuranceFee: 4500,
          autoTax: 10800,
          inspectionFee: 60000, // 4WDで若干整備費高め
          fuelEfficiency: 14,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 8000,
          tireFee: 10000, // 175/80R16 オフロード寄りで割高
          maintenanceFee: 22000,
        },
      },
    ],
  },
  {
    name: "コンパクトカー",
    icon: "🚗",
    models: [
      {
        name: "ヤリス",
        maker: "トヨタ",
        category: "コンパクトカー",
        displacementCc: 1490,
        fuelType: "regular",
        values: {
          name: "ヤリス (トヨタ)",
          vehiclePrice: 2000000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 12000,
          insuranceFee: 5000,
          autoTax: 30500, // 1.0〜1.5L
          inspectionFee: 75000, // 法定費用43,000+整備32,000
          fuelEfficiency: 21,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 10000, // 175/70R14 4本40,000円/4年
          maintenanceFee: 22000,
        },
      },
      {
        name: "フィット",
        maker: "ホンダ",
        category: "コンパクトカー",
        displacementCc: 1496,
        fuelType: "regular",
        values: {
          name: "フィット (ホンダ)",
          vehiclePrice: 1950000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 12000,
          insuranceFee: 5000,
          autoTax: 30500,
          inspectionFee: 75000,
          fuelEfficiency: 20,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 10000,
          maintenanceFee: 22000,
        },
      },
      {
        name: "ノート",
        maker: "日産",
        category: "コンパクトカー",
        displacementCc: 1198,
        fuelType: "regular",
        values: {
          name: "ノート (日産)",
          vehiclePrice: 2350000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 12000,
          insuranceFee: 5000,
          autoTax: 30500, // 1.0〜1.5L（e-POWER発電用1.2L）
          inspectionFee: 80000,
          fuelEfficiency: 28,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 10000,
          maintenanceFee: 22000,
        },
      },
      {
        name: "アクア",
        maker: "トヨタ",
        category: "コンパクトカー",
        displacementCc: 1490,
        fuelType: "regular",
        values: {
          name: "アクア (トヨタ)",
          vehiclePrice: 2200000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 12000,
          insuranceFee: 5000,
          autoTax: 30500,
          inspectionFee: 80000,
          fuelEfficiency: 33,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 10000,
          maintenanceFee: 22000,
        },
      },
      {
        name: "ルーミー",
        maker: "トヨタ",
        category: "コンパクトカー",
        displacementCc: 996,
        fuelType: "regular",
        values: {
          name: "ルーミー (トヨタ)",
          vehiclePrice: 1900000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 12000,
          insuranceFee: 5000,
          autoTax: 25000, // 1.0L以下
          inspectionFee: 75000,
          fuelEfficiency: 18,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 10000,
          maintenanceFee: 22000,
        },
      },
    ],
  },
  {
    name: "セダン・ワゴン",
    icon: "🚘",
    models: [
      {
        name: "カローラ",
        maker: "トヨタ",
        category: "セダン・ワゴン",
        displacementCc: 1797,
        fuelType: "regular",
        values: {
          name: "カローラ (トヨタ)",
          vehiclePrice: 2550000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 5500,
          autoTax: 36000, // 1.5〜2.0L
          inspectionFee: 90000, // 法定費用43,000+整備47,000
          fuelEfficiency: 19,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 13000, // 195/65R15 4本50,000円/4年
          maintenanceFee: 28000,
        },
      },
      {
        name: "プリウス",
        maker: "トヨタ",
        category: "セダン・ワゴン",
        displacementCc: 1986,
        fuelType: "regular",
        values: {
          name: "プリウス (トヨタ)",
          vehiclePrice: 3300000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6000,
          autoTax: 36000, // 1.5〜2.0L
          inspectionFee: 95000,
          fuelEfficiency: 28,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 15000, // 195/50R19 HV専用タイヤで割高
          maintenanceFee: 28000,
        },
      },
      {
        name: "インプレッサ",
        maker: "スバル",
        category: "セダン・ワゴン",
        displacementCc: 1995,
        fuelType: "regular",
        values: {
          name: "インプレッサ (スバル)",
          vehiclePrice: 2700000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 5500,
          autoTax: 36000,
          inspectionFee: 95000,
          fuelEfficiency: 14,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 14000, // 205/50R17
          maintenanceFee: 28000,
        },
      },
      {
        name: "クラウン",
        maker: "トヨタ",
        category: "セダン・ワゴン",
        displacementCc: 2487,
        fuelType: "regular",
        values: {
          name: "クラウン (トヨタ)",
          vehiclePrice: 5100000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 20000,
          insuranceFee: 9000,
          autoTax: 43500, // 2.0〜2.5L
          inspectionFee: 130000,
          fuelEfficiency: 18,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 25000, // 225/45R21 大径で高額
          maintenanceFee: 40000,
        },
      },
    ],
  },
  {
    name: "ミニバン",
    icon: "🚐",
    models: [
      {
        name: "シエンタ",
        maker: "トヨタ",
        category: "ミニバン",
        displacementCc: 1490,
        fuelType: "regular",
        values: {
          name: "シエンタ (トヨタ)",
          vehiclePrice: 2700000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6000,
          autoTax: 30500, // 1.0〜1.5L
          inspectionFee: 85000,
          fuelEfficiency: 18,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 12000, // 185/65R15
          maintenanceFee: 28000,
        },
      },
      {
        name: "フリード",
        maker: "ホンダ",
        category: "ミニバン",
        displacementCc: 1496,
        fuelType: "regular",
        values: {
          name: "フリード (ホンダ)",
          vehiclePrice: 2850000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6000,
          autoTax: 30500,
          inspectionFee: 85000,
          fuelEfficiency: 17,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 12000,
          maintenanceFee: 28000,
        },
      },
      {
        name: "ノア / ヴォクシー",
        maker: "トヨタ",
        category: "ミニバン",
        displacementCc: 1797,
        fuelType: "regular",
        values: {
          name: "ノア (トヨタ)",
          vehiclePrice: 3400000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 7000,
          autoTax: 36000, // 1.5〜2.0L
          inspectionFee: 100000,
          fuelEfficiency: 15,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 15000, // 205/60R16
          maintenanceFee: 32000,
        },
      },
      {
        name: "セレナ",
        maker: "日産",
        category: "ミニバン",
        displacementCc: 1433,
        fuelType: "regular",
        values: {
          name: "セレナ (日産)",
          vehiclePrice: 3500000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 7000,
          autoTax: 30500, // e-POWER 1.4L
          inspectionFee: 100000,
          fuelEfficiency: 18,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 15000,
          maintenanceFee: 32000,
        },
      },
      {
        name: "ステップワゴン",
        maker: "ホンダ",
        category: "ミニバン",
        displacementCc: 1496,
        fuelType: "regular",
        values: {
          name: "ステップワゴン (ホンダ)",
          vehiclePrice: 3500000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 7000,
          autoTax: 30500, // 1.5L
          inspectionFee: 100000,
          fuelEfficiency: 14,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 15000,
          maintenanceFee: 32000,
        },
      },
      {
        name: "アルファード",
        maker: "トヨタ",
        category: "ミニバン",
        displacementCc: 2487,
        fuelType: "regular",
        values: {
          name: "アルファード (トヨタ)",
          vehiclePrice: 5500000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 20000,
          insuranceFee: 10000,
          autoTax: 43500, // 2.0〜2.5L
          inspectionFee: 140000,
          fuelEfficiency: 10,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 22000, // 225/60R18
          maintenanceFee: 40000,
        },
      },
    ],
  },
  {
    name: "SUV・クロスオーバー",
    icon: "🏔️",
    models: [
      {
        name: "ヤリスクロス",
        maker: "トヨタ",
        category: "SUV・クロスオーバー",
        displacementCc: 1490,
        fuelType: "regular",
        values: {
          name: "ヤリスクロス (トヨタ)",
          vehiclePrice: 2350000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 12000,
          insuranceFee: 5500,
          autoTax: 30500, // 1.0〜1.5L
          inspectionFee: 85000,
          fuelEfficiency: 20,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 13000, // 215/50R18
          maintenanceFee: 25000,
        },
      },
      {
        name: "ヴェゼル",
        maker: "ホンダ",
        category: "SUV・クロスオーバー",
        displacementCc: 1496,
        fuelType: "regular",
        values: {
          name: "ヴェゼル (ホンダ)",
          vehiclePrice: 2800000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6000,
          autoTax: 30500,
          inspectionFee: 90000,
          fuelEfficiency: 17,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 15000, // 225/50R18
          maintenanceFee: 28000,
        },
      },
      {
        name: "カローラクロス",
        maker: "トヨタ",
        category: "SUV・クロスオーバー",
        displacementCc: 1797,
        fuelType: "regular",
        values: {
          name: "カローラクロス (トヨタ)",
          vehiclePrice: 2900000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6000,
          autoTax: 36000, // 1.5〜2.0L
          inspectionFee: 95000,
          fuelEfficiency: 18,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 15000,
          maintenanceFee: 28000,
        },
      },
      {
        name: "RAV4",
        maker: "トヨタ",
        category: "SUV・クロスオーバー",
        displacementCc: 1986,
        fuelType: "regular",
        values: {
          name: "RAV4 (トヨタ)",
          vehiclePrice: 3600000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6500,
          autoTax: 36000,
          inspectionFee: 105000,
          fuelEfficiency: 15,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 18000, // 225/60R18
          maintenanceFee: 30000,
        },
      },
      {
        name: "ハリアー",
        maker: "トヨタ",
        category: "SUV・クロスオーバー",
        displacementCc: 1986,
        fuelType: "regular",
        values: {
          name: "ハリアー (トヨタ)",
          vehiclePrice: 4000000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 7000,
          autoTax: 36000, // 1.5〜2.0L（2.0L HV）
          inspectionFee: 110000,
          fuelEfficiency: 15,
          fuelPrice: DEFAULT_FUEL_PRICE,
          annualMileage: 10000,
          tireFee: 20000, // 225/55R19
          maintenanceFee: 32000,
        },
      },
      {
        name: "CX-5",
        maker: "マツダ",
        category: "SUV・クロスオーバー",
        displacementCc: 2188,
        fuelType: "diesel",
        values: {
          name: "CX-5 (マツダ)",
          vehiclePrice: 3200000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 15000,
          insuranceFee: 6500,
          autoTax: 43500, // 2.0〜2.5L（ディーゼル2.2L）
          inspectionFee: 105000,
          fuelEfficiency: 17,
          fuelPrice: FUEL_PRICES.diesel, // 軽油
          annualMileage: 10000,
          tireFee: 18000,
          maintenanceFee: 30000,
        },
      },
      {
        name: "ランドクルーザー",
        maker: "トヨタ",
        category: "SUV・クロスオーバー",
        displacementCc: 3444,
        fuelType: "diesel",
        values: {
          name: "ランドクルーザー (トヨタ)",
          vehiclePrice: 7300000,
          downPayment: 0,
          interestRate: 3.0,
          loanYears: 5,
          parkingFee: 20000,
          insuranceFee: 12000,
          autoTax: 57000, // 3.0〜3.5L（ディーゼル3.3L）
          inspectionFee: 160000,
          fuelEfficiency: 9,
          fuelPrice: FUEL_PRICES.diesel,
          annualMileage: 10000,
          tireFee: 35000, // 265/65R18 大型タイヤ
          maintenanceFee: 50000,
        },
      },
    ],
  },
];
