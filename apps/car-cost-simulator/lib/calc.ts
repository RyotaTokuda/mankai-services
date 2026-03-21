import type { CarScenario, CostBreakdown } from "./types";

export function calculateCosts(scenario: CarScenario): CostBreakdown {
  const {
    vehiclePrice,
    downPayment,
    interestRate,
    loanYears,
    parkingFee,
    insuranceFee,
    autoTax,
    inspectionFee,
    fuelEfficiency,
    fuelPrice,
    annualMileage,
    tireFee,
    maintenanceFee,
  } = scenario;

  // ローン計算（元利均等返済）
  const principal = Math.max(vehiclePrice - downPayment, 0);
  let loanMonthly = 0;
  let loanTotal = 0;

  if (principal > 0 && loanYears > 0) {
    const monthlyRate = interestRate / 100 / 12;
    const totalPayments = loanYears * 12;

    if (monthlyRate > 0) {
      loanMonthly =
        (principal * monthlyRate * Math.pow(1 + monthlyRate, totalPayments)) /
        (Math.pow(1 + monthlyRate, totalPayments) - 1);
    } else {
      loanMonthly = principal / totalPayments;
    }
    loanTotal = loanMonthly * totalPayments;
  }

  // 年額換算
  const parkingAnnual = parkingFee * 12;
  const insuranceAnnual = insuranceFee * 12;
  const inspectionAnnual = inspectionFee / 2; // 2年に1回
  const fuelAnnual =
    fuelEfficiency > 0 ? (annualMileage / fuelEfficiency) * fuelPrice : 0;

  // 合計
  const totalAnnual =
    loanMonthly * 12 +
    parkingAnnual +
    insuranceAnnual +
    autoTax +
    inspectionAnnual +
    fuelAnnual +
    tireFee +
    maintenanceFee;

  const totalMonthly = totalAnnual / 12;
  const totalFiveYear = totalAnnual * 5;

  return {
    loanMonthly: Math.round(loanMonthly),
    loanTotal: Math.round(loanTotal),
    parkingAnnual: Math.round(parkingAnnual),
    insuranceAnnual: Math.round(insuranceAnnual),
    autoTax,
    inspectionAnnual: Math.round(inspectionAnnual),
    fuelAnnual: Math.round(fuelAnnual),
    tireAnnual: tireFee,
    maintenanceAnnual: maintenanceFee,
    totalMonthly: Math.round(totalMonthly),
    totalAnnual: Math.round(totalAnnual),
    totalFiveYear: Math.round(totalFiveYear),
  };
}

export function formatYen(value: number): string {
  return value.toLocaleString("ja-JP");
}
