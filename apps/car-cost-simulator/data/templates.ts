/**
 * カテゴリ別テンプレート マスターデータ
 *
 * 車種を決めていないユーザー向けの、カテゴリごとの平均的な試算条件
 * 個別車種のデータは data/car-models.ts を参照
 *
 * 更新日: 2026-03-21
 */

import type { CarScenario } from "../lib/types";
import { DEFAULT_FUEL_PRICE, FUEL_PRICES } from "./fuel-price";

export interface Template {
  name: string;
  icon: string;
  description: string;
  values: Omit<CarScenario, "id">;
}

export const TEMPLATES: Template[] = [
  {
    name: "軽自動車",
    icon: "🚙",
    description: "N-BOX, タント, スペーシアなど",
    values: {
      name: "軽自動車",
      vehiclePrice: 1600000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 8000,
      insuranceFee: 4000,
      autoTax: 10800, // 軽自動車一律
      inspectionFee: 55000, // 法定27,000+整備28,000
      fuelEfficiency: 20,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 8000,
      tireFee: 7000, // 155/65R14 4本28,000円/4年
      maintenanceFee: 18000,
    },
  },
  {
    name: "コンパクトカー (1.0〜1.5L)",
    icon: "🚗",
    description: "ヤリス, フィット, ノートなど",
    values: {
      name: "コンパクトカー",
      vehiclePrice: 2000000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 12000,
      insuranceFee: 5000,
      autoTax: 30500, // 1.0〜1.5L
      inspectionFee: 75000, // 法定43,000+整備32,000
      fuelEfficiency: 18,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 10000,
      tireFee: 10000, // 175/70R14 4本40,000円/4年
      maintenanceFee: 22000,
    },
  },
  {
    name: "セダン・ワゴン (1.5〜2.0L)",
    icon: "🚘",
    description: "カローラ, インプレッサ, MAZDA3など",
    values: {
      name: "セダン (2.0L)",
      vehiclePrice: 2800000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 15000,
      insuranceFee: 6000,
      autoTax: 36000, // 1.5〜2.0L
      inspectionFee: 90000,
      fuelEfficiency: 15,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 10000,
      tireFee: 13000, // 195/65R15
      maintenanceFee: 28000,
    },
  },
  {
    name: "ミニバン (1.5〜2.5L)",
    icon: "🚐",
    description: "ノア, セレナ, ステップワゴンなど",
    values: {
      name: "ミニバン",
      vehiclePrice: 3500000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 15000,
      insuranceFee: 7000,
      autoTax: 36000, // 代表的な1.5〜2.0Lクラス
      inspectionFee: 100000,
      fuelEfficiency: 13,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 10000,
      tireFee: 15000, // 205/60R16
      maintenanceFee: 32000,
    },
  },
  {
    name: "SUV (2.0〜2.5L)",
    icon: "🏔️",
    description: "RAV4, フォレスター, CX-5など",
    values: {
      name: "SUV",
      vehiclePrice: 3200000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 15000,
      insuranceFee: 6500,
      autoTax: 36000, // 2.0Lクラスが主流
      inspectionFee: 100000,
      fuelEfficiency: 14,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 10000,
      tireFee: 18000, // 225/60R18
      maintenanceFee: 30000,
    },
  },
  {
    name: "大型車・高級車 (2.5L〜)",
    icon: "✨",
    description: "アルファード, クラウン, ランクルなど",
    values: {
      name: "大型車",
      vehiclePrice: 5500000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 20000,
      insuranceFee: 10000,
      autoTax: 43500, // 2.0〜2.5L（多くの大型車はHVで2.5L）
      inspectionFee: 140000,
      fuelEfficiency: 10,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 10000,
      tireFee: 25000,
      maintenanceFee: 40000,
    },
  },
  {
    name: "ハイブリッド (1.5〜2.0L)",
    icon: "🍃",
    description: "プリウス, アクア, フィットHVなど",
    values: {
      name: "ハイブリッド",
      vehiclePrice: 2800000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 12000,
      insuranceFee: 5500,
      autoTax: 36000,
      inspectionFee: 90000,
      fuelEfficiency: 25,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 10000,
      tireFee: 13000,
      maintenanceFee: 25000,
    },
  },
  {
    name: "軽トラ・軽バン",
    icon: "🛻",
    description: "ハイゼット, キャリイ, エブリイなど",
    values: {
      name: "軽トラ・軽バン",
      vehiclePrice: 1100000,
      downPayment: 0,
      interestRate: 3.0,
      loanYears: 5,
      parkingFee: 5000,
      insuranceFee: 3500,
      autoTax: 5000, // 軽貨物（自家用）
      inspectionFee: 45000, // 軽貨物は法定費用が安い
      fuelEfficiency: 16,
      fuelPrice: DEFAULT_FUEL_PRICE,
      annualMileage: 12000,
      tireFee: 5000, // 145R12 商用タイヤ安価
      maintenanceFee: 18000,
    },
  },
];
