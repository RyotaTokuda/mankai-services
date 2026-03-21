import type { CarScenario } from "./types";

/** シナリオをクエリパラメータ用に圧縮エンコード */
export function encodeScenarios(scenarios: CarScenario[]): string {
  const data = scenarios.map((s) => ({
    n: s.name,
    vp: s.vehiclePrice,
    dp: s.downPayment,
    ir: s.interestRate,
    ly: s.loanYears,
    pf: s.parkingFee,
    if: s.insuranceFee,
    at: s.autoTax,
    inf: s.inspectionFee,
    fe: s.fuelEfficiency,
    fp: s.fuelPrice,
    am: s.annualMileage,
    tf: s.tireFee,
    mf: s.maintenanceFee,
  }));
  return btoa(encodeURIComponent(JSON.stringify(data)));
}

/** クエリパラメータからシナリオを復元 */
export function decodeScenarios(encoded: string): CarScenario[] | null {
  try {
    const json = decodeURIComponent(atob(encoded));
    const data = JSON.parse(json) as Array<Record<string, unknown>>;
    return data.map((d) => ({
      id: crypto.randomUUID(),
      name: String(d.n || "車種"),
      vehiclePrice: Number(d.vp) || 0,
      downPayment: Number(d.dp) || 0,
      interestRate: Number(d.ir) || 3.0,
      loanYears: Number(d.ly) || 5,
      parkingFee: Number(d.pf) || 0,
      insuranceFee: Number(d.if) || 0,
      autoTax: Number(d.at) || 0,
      inspectionFee: Number(d.inf) || 0,
      fuelEfficiency: Number(d.fe) || 15,
      fuelPrice: Number(d.fp) || 175,
      annualMileage: Number(d.am) || 10000,
      tireFee: Number(d.tf) || 0,
      maintenanceFee: Number(d.mf) || 0,
    }));
  } catch {
    return null;
  }
}

/** 現在のシナリオでシェアURLを生成 */
export function buildShareUrl(scenarios: CarScenario[]): string {
  const base =
    typeof window !== "undefined"
      ? window.location.origin + window.location.pathname
      : "https://kuraberu-lab.com/tools/car-cost/";
  return `${base}?s=${encodeScenarios(scenarios)}`;
}
