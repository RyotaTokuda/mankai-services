export interface CarScenario {
  id: string;
  name: string;
  // 車両本体
  vehiclePrice: number; // 車両価格（税込）
  downPayment: number; // 頭金
  interestRate: number; // 金利（%）
  loanYears: number; // ローン年数
  // 固定費（月額）
  parkingFee: number; // 駐車場代
  insuranceFee: number; // 任意保険（月額）
  // 固定費（年額）
  autoTax: number; // 自動車税（年額）
  // 車検（2年ごと）
  inspectionFee: number; // 車検費用（1回あたり）
  // 燃料
  fuelEfficiency: number; // 燃費（km/L）
  fuelPrice: number; // ガソリン単価（円/L）
  annualMileage: number; // 年間走行距離（km）
  // その他（年額）
  tireFee: number; // タイヤ交換（年あたり按分）
  maintenanceFee: number; // 消耗品・整備（年あたり）
  resaleRate: number; // 5年後リセール率（%）
}

export interface CostBreakdown {
  loanMonthly: number;
  loanTotal: number;
  parkingAnnual: number;
  insuranceAnnual: number;
  autoTax: number;
  inspectionAnnual: number; // 年あたり按分
  fuelAnnual: number;
  tireAnnual: number;
  maintenanceAnnual: number;
  totalMonthly: number;
  totalAnnual: number;
  totalFiveYear: number;
}

// DEFAULT_FUEL_PRICE は data/fuel-price.ts で一元管理
// eslint-disable-next-line @typescript-eslint/no-require-imports
import { DEFAULT_FUEL_PRICE } from "../data/fuel-price";

export const DEFAULT_SCENARIO: Omit<CarScenario, "id"> = {
  name: "車種 1",
  vehiclePrice: 2000000,
  downPayment: 0,
  interestRate: 3.0,
  loanYears: 5,
  parkingFee: 15000,
  insuranceFee: 5000,
  autoTax: 30500,
  inspectionFee: 75000,
  fuelEfficiency: 18,
  fuelPrice: DEFAULT_FUEL_PRICE,
  annualMileage: 10000,
  tireFee: 10000,
  maintenanceFee: 22000,
  resaleRate: 40,
};
