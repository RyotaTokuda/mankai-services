import jsPDF from "jspdf";
import type { CarScenario, CostBreakdown } from "./types";
import { formatYen } from "./calc";

interface Result {
  scenario: CarScenario;
  costs: CostBreakdown;
}

export function exportPdf(results: Result[]) {
  const doc = new jsPDF({ orientation: "portrait", unit: "mm", format: "a4" });
  const pageWidth = doc.internal.pageSize.getWidth();
  let y = 20;

  // タイトル
  doc.setFontSize(18);
  doc.text("車の維持費シミュレーション結果", pageWidth / 2, y, {
    align: "center",
  });
  y += 10;
  doc.setFontSize(9);
  doc.setTextColor(150);
  doc.text(
    `くらべるラボ | ${new Date().toLocaleDateString("ja-JP")} 作成`,
    pageWidth / 2,
    y,
    { align: "center" }
  );
  doc.setTextColor(0);
  y += 12;

  for (const { scenario, costs } of results) {
    if (y > 250) {
      doc.addPage();
      y = 20;
    }

    // 車種名
    doc.setFontSize(14);
    doc.text(scenario.name, 15, y);
    y += 8;

    // 主要数値
    doc.setFontSize(11);
    const summaryData = [
      ["月額", `${formatYen(costs.totalMonthly)} 円`],
      ["年額", `${formatYen(costs.totalAnnual)} 円`],
      ["5年総額", `${formatYen(costs.totalFiveYear)} 円`],
    ];
    for (const [label, value] of summaryData) {
      doc.setTextColor(100);
      doc.text(label, 20, y);
      doc.setTextColor(0);
      doc.setFont(undefined!, "bold");
      doc.text(value, 55, y);
      doc.setFont(undefined!, "normal");
      y += 6;
    }
    y += 2;

    // 内訳
    doc.setFontSize(10);
    doc.setTextColor(100);
    doc.text("内訳（月額換算）", 20, y);
    doc.setTextColor(0);
    y += 6;

    doc.setFontSize(9);
    const breakdownData = [
      ["ローン返済", costs.loanMonthly],
      ["駐車場代", costs.parkingAnnual / 12],
      ["任意保険", costs.insuranceAnnual / 12],
      ["自動車税", costs.autoTax / 12],
      ["車検", costs.inspectionAnnual / 12],
      ["燃料費", costs.fuelAnnual / 12],
      ["タイヤ", costs.tireAnnual / 12],
      ["消耗品・整備", costs.maintenanceAnnual / 12],
    ];
    for (const [label, value] of breakdownData) {
      doc.setTextColor(120);
      doc.text(String(label), 25, y);
      doc.setTextColor(0);
      doc.text(`${formatYen(Math.round(Number(value)))} 円/月`, 70, y);
      y += 5;
    }
    y += 4;

    // 試算条件
    doc.setFontSize(9);
    doc.setTextColor(150);
    doc.text(
      `車両価格: ${formatYen(scenario.vehiclePrice)}円 / 頭金: ${formatYen(scenario.downPayment)}円 / 金利: ${scenario.interestRate}% / ${scenario.loanYears}年ローン`,
      20,
      y
    );
    y += 5;
    doc.text(
      `燃費: ${scenario.fuelEfficiency}km/L / 年間走行: ${formatYen(scenario.annualMileage)}km / ガソリン: ${scenario.fuelPrice}円/L`,
      20,
      y
    );
    doc.setTextColor(0);
    y += 10;

    // 区切り線
    doc.setDrawColor(220);
    doc.line(15, y, pageWidth - 15, y);
    y += 8;
  }

  // 比較サマリー（2台以上）
  if (results.length > 1) {
    if (y > 230) {
      doc.addPage();
      y = 20;
    }
    doc.setFontSize(12);
    doc.text("比較サマリー", 15, y);
    y += 8;

    doc.setFontSize(9);
    // ヘッダー
    doc.setTextColor(100);
    doc.text("", 20, y);
    let x = 60;
    for (const { scenario } of results) {
      doc.text(scenario.name, x, y, { align: "right" });
      x += 40;
    }
    y += 6;
    doc.setTextColor(0);

    const compareRows = [
      { label: "月額", values: results.map((r) => r.costs.totalMonthly) },
      { label: "年額", values: results.map((r) => r.costs.totalAnnual) },
      {
        label: "5年総額",
        values: results.map((r) => r.costs.totalFiveYear),
      },
    ];
    for (const row of compareRows) {
      doc.text(row.label, 20, y);
      let xPos = 60;
      for (const v of row.values) {
        doc.text(`${formatYen(v)} 円`, xPos, y, { align: "right" });
        xPos += 40;
      }
      y += 5;
    }
  }

  // フッター
  doc.setFontSize(8);
  doc.setTextColor(180);
  doc.text(
    "※ 本試算は目安です。実際の維持費は条件により異なります。",
    pageWidth / 2,
    285,
    { align: "center" }
  );
  doc.text("kuraberu-lab.com/tools/car-cost/", pageWidth / 2, 289, {
    align: "center",
  });

  doc.save("car-cost-simulation.pdf");
}
