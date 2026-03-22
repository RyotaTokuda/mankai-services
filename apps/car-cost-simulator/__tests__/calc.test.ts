import { describe, it, expect } from "vitest";
import { calculateCosts, formatYen } from "../lib/calc";
import type { CarScenario } from "../lib/types";

const BASE: CarScenario = {
  id: "test-1",
  name: "テスト車",
  vehiclePrice: 2_000_000,
  downPayment: 0,
  interestRate: 3.0,
  loanYears: 5,
  parkingFee: 15_000,
  insuranceFee: 5_000,
  autoTax: 30_500,
  inspectionFee: 75_000,
  fuelEfficiency: 18,
  fuelPrice: 175,
  annualMileage: 10_000,
  tireFee: 10_000,
  maintenanceFee: 22_000,
  resaleRate: 40,
};

describe("calculateCosts", () => {
  it("ローン月額が正の値になる", () => {
    const result = calculateCosts(BASE);
    expect(result.loanMonthly).toBeGreaterThan(0);
  });

  it("頭金が車両価格を超える場合、ローンは0", () => {
    const result = calculateCosts({ ...BASE, downPayment: 3_000_000 });
    expect(result.loanMonthly).toBe(0);
    expect(result.loanTotal).toBe(0);
  });

  it("金利0%なら元本÷回数の均等割", () => {
    const result = calculateCosts({
      ...BASE,
      vehiclePrice: 1_200_000,
      downPayment: 0,
      interestRate: 0,
      loanYears: 5,
    });
    expect(result.loanMonthly).toBe(20_000);
    expect(result.loanTotal).toBe(1_200_000);
  });

  it("燃費0の場合、燃料費は0", () => {
    const result = calculateCosts({ ...BASE, fuelEfficiency: 0 });
    expect(result.fuelAnnual).toBe(0);
  });

  it("車検費用は2年に1回で年額按分", () => {
    const result = calculateCosts({ ...BASE, inspectionFee: 100_000 });
    expect(result.inspectionAnnual).toBe(50_000);
  });

  it("月額 = 年額 / 12", () => {
    const result = calculateCosts(BASE);
    expect(result.totalMonthly).toBe(Math.round(result.totalAnnual / 12));
  });

  it("5年総額 ≈ 年額 × 5（丸め誤差1円以内）", () => {
    const result = calculateCosts(BASE);
    expect(Math.abs(result.totalFiveYear - result.totalAnnual * 5)).toBeLessThanOrEqual(1);
  });

  it("燃料費の計算が正しい", () => {
    const result = calculateCosts({
      ...BASE,
      fuelEfficiency: 20,
      fuelPrice: 160,
      annualMileage: 10_000,
    });
    // 10000km / 20km/L * 160円 = 80,000円
    expect(result.fuelAnnual).toBe(80_000);
  });
});

describe("formatYen", () => {
  it("カンマ区切りでフォーマットする", () => {
    expect(formatYen(1_234_567)).toBe("1,234,567");
  });

  it("0はそのまま", () => {
    expect(formatYen(0)).toBe("0");
  });
});
