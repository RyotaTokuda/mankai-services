import { describe, it, expect } from "vitest";
import { encodeScenarios, decodeScenarios } from "../lib/url-share";
import type { CarScenario } from "../lib/types";

const SAMPLE: CarScenario = {
  id: "test-1",
  name: "N-BOX",
  vehiclePrice: 1_800_000,
  downPayment: 200_000,
  interestRate: 2.5,
  loanYears: 5,
  parkingFee: 10_000,
  insuranceFee: 4_000,
  autoTax: 10_800,
  inspectionFee: 60_000,
  fuelEfficiency: 21,
  fuelPrice: 175,
  annualMileage: 8_000,
  tireFee: 8_000,
  maintenanceFee: 15_000,
  resaleRate: 50,
};

describe("URL共有 encode/decode", () => {
  it("エンコード→デコードで元データが復元される", () => {
    const encoded = encodeScenarios([SAMPLE]);
    const decoded = decodeScenarios(encoded);

    expect(decoded).not.toBeNull();
    expect(decoded!.length).toBe(1);

    const d = decoded![0];
    expect(d.name).toBe("N-BOX");
    expect(d.vehiclePrice).toBe(1_800_000);
    expect(d.downPayment).toBe(200_000);
    expect(d.interestRate).toBe(2.5);
    expect(d.loanYears).toBe(5);
    expect(d.parkingFee).toBe(10_000);
    expect(d.insuranceFee).toBe(4_000);
    expect(d.autoTax).toBe(10_800);
    expect(d.inspectionFee).toBe(60_000);
    expect(d.fuelEfficiency).toBe(21);
    expect(d.fuelPrice).toBe(175);
    expect(d.annualMileage).toBe(8_000);
    expect(d.tireFee).toBe(8_000);
    expect(d.maintenanceFee).toBe(15_000);
    expect(d.resaleRate).toBe(50);
  });

  it("複数シナリオでも正しく復元される", () => {
    const second: CarScenario = { ...SAMPLE, id: "test-2", name: "タント" };
    const encoded = encodeScenarios([SAMPLE, second]);
    const decoded = decodeScenarios(encoded);

    expect(decoded!.length).toBe(2);
    expect(decoded![0].name).toBe("N-BOX");
    expect(decoded![1].name).toBe("タント");
  });

  it("デコードされたシナリオにはidが新規生成される", () => {
    const encoded = encodeScenarios([SAMPLE]);
    const decoded = decodeScenarios(encoded);
    expect(decoded![0].id).toBeDefined();
    expect(decoded![0].id).not.toBe("test-1");
  });

  it("不正な文字列はnullを返す", () => {
    expect(decodeScenarios("invalid-base64!!!")).toBeNull();
  });

  it("空文字列はnullを返す", () => {
    expect(decodeScenarios("")).toBeNull();
  });
});
