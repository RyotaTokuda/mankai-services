// npx tsx src/lib/calculateFee.test.ts で実行
import { calculateFee } from "./calculateFee";
import type { ParkingZone } from "../types/parking";

let pass = 0, fail = 0;

function test(label: string, entry: string, exit: string, zone: ParkingZone, expected: number) {
  const result = calculateFee(new Date(entry), new Date(exit), zone);
  const ok = result.total === expected;
  if (ok) {
    pass++;
    console.log(`  ✅ ${label}: ¥${result.total}`);
  } else {
    fail++;
    console.log(`  ❌ ${label}: 期待:¥${expected} 実際:¥${result.total}`);
    for (const b of result.breakdown) {
      console.log(`     ${b.label} ${b.minutes}分 ¥${b.subtotal} (segStart=${b.segmentStartHour})`);
    }
    console.log(`     rawTotal=¥${result.rawTotal} maxApplied=[${result.maxPricesApplied.join(", ")}]`);
  }
}

// ─── ゾーン定義 ───────────────────────────────────────────

// 1. シンプル: 8-22 30分200円、22-8 60分100円、当日最大1200円
const ZONE_SIMPLE: ParkingZone = {
  name: "全車種",
  slots: [
    { startHour: 8, endHour: 22, unitMinutes: 30, unitPrice: 200 },
    { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 100 },
  ],
  maxPrices: [{ amount: 1200, type: "per_day", label: "当日最大" }],
};

// 2. TOWAタイムパーク風: 全時間帯 20分200円、昼間最大(7-21)¥900、夜間最大(21-7)¥500
const ZONE_TOWA: ParkingZone = {
  name: "全車種",
  slots: [
    { startHour: 0, endHour: 24, unitMinutes: 20, unitPrice: 200 },
  ],
  maxPrices: [
    { amount: 900, type: "per_period", label: "昼間最大", startHour: 7, endHour: 21 },
    { amount: 500, type: "per_period", label: "夜間最大", startHour: 21, endHour: 7 },
  ],
};

// 3. NPC保土ヶ谷風: 8-22 20分100円、22-8 60分100円、夜間最大(22-8)¥600
const ZONE_NPC: ParkingZone = {
  name: "全車種",
  slots: [
    { startHour: 8, endHour: 22, unitMinutes: 20, unitPrice: 100 },
    { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 100 },
  ],
  maxPrices: [
    { amount: 600, type: "per_period", label: "夜間最大", startHour: 22, endHour: 8 },
  ],
};

// 4. 24時間最大2000円: 全時間帯 30分300円
const ZONE_24H_ONCE: ParkingZone = {
  name: "全車種",
  slots: [{ startHour: 0, endHour: 24, unitMinutes: 30, unitPrice: 300 }],
  maxPrices: [{ amount: 2000, type: "per_24h_once", label: "24時間最大" }],
};

// 5. 24時間ごと繰り返し最大1500円: 全時間帯 30分200円
const ZONE_24H_REPEAT: ParkingZone = {
  name: "全車種",
  slots: [{ startHour: 0, endHour: 24, unitMinutes: 30, unitPrice: 200 }],
  maxPrices: [{ amount: 1500, type: "per_24h_repeat", label: "24時間ごと最大" }],
};

// ─── テスト ────────────────────────────────────────────────

console.log("\n【シンプル: 8-22 30分200円 / 22-8 60分100円 / 当日最大1200円】");
// 昼間1h = ceil(60/30)*200 = 400
test("昼間1h", "2026-03-17T10:00", "2026-03-17T11:00", ZONE_SIMPLE, 400);
// 夜間2h = ceil(120/60)*100 = 200
test("夜間2h", "2026-03-17T22:00", "2026-03-18T00:00", ZONE_SIMPLE, 200);
// 昼間フル 8-22 = 14h = ceil(840/30)*200=5600 → 当日最大1200
test("昼間フル→当日最大", "2026-03-17T08:00", "2026-03-17T22:00", ZONE_SIMPLE, 1200);
// 昼間15分 = ceil(15/30)*200 = 200
test("昼間15分", "2026-03-17T10:00", "2026-03-17T10:15", ZONE_SIMPLE, 200);
// 日跨ぎ: 22:00〜翌2:00 夜間4h = ceil(240/60)*100=400、翌日リセット後も夜間(0-8)
// 22:00〜0:00 (昨日分) = 200 → byDay["2026-03-17"]
// 0:00〜2:00 = 200 → byDay["2026-03-18"]
// 各日 200 < 1200 → total=400（最大適用なし）
test("日跨ぎ夜間4h", "2026-03-17T22:00", "2026-03-18T02:00", ZONE_SIMPLE, 400);

console.log("\n【TOWA風: 全時間帯20分200円 / 昼間最大(7-21)¥900 / 夜間最大(21-7)¥500】");
// 昼間フル(7-21) = 14h = ceil(840/20)*200=8400 → 昼間最大900
test("昼間フル→昼間最大", "2026-03-17T07:00", "2026-03-17T21:00", ZONE_TOWA, 900);
// 夜間3h(21-24) = ceil(180/20)*200=1800 → 夜間最大500
test("夜間3h→夜間最大", "2026-03-17T21:00", "2026-03-18T00:00", ZONE_TOWA, 500);
// 夜間1h(22-23) = ceil(60/20)*200=600 → 夜間最大500
test("夜間1h→夜間最大(600→500)", "2026-03-17T22:00", "2026-03-17T23:00", ZONE_TOWA, 500);
// 夜間20分(22:00-22:20) = ceil(20/20)*200=200 < 500 → キャップ未適用
test("夜間20分(キャップ未満)", "2026-03-17T22:00", "2026-03-17T22:20", ZONE_TOWA, 200);
// 0時〜24時: 0-7(夜間前半) + 7-21(昼間) + 21-24(夜間後半)
// 0-7: segStart=0 → 夜間期間 → belongs to prev night "2026-03-16" → 420min=21seg=4200
// 7-21: segStart=7 → 昼間 → 840min=42seg=8400 → cap 900
// 21-24: segStart=21 → 夜間 → "2026-03-17" → 180min=9seg=1800
// 夜間"2026-03-16"=4200 > 500 → cap 500
// 夜間"2026-03-17"=1800 > 500 → cap 500
// 昼間"2026-03-17"=8400 → cap 900
// total = 500+500+900 = 1900
test("0時〜24時(1日まるごと)", "2026-03-17T00:00", "2026-03-18T00:00", ZONE_TOWA, 1900);

console.log("\n【NPC保土ヶ谷風: 8-22 20分100円 / 22-8 60分100円 / 夜間最大(22-8)¥600】");
// 夜間7h(22:00〜05:00) = ceil(420/60)*100=700 → 夜間最大600
test("夜間7h→夜間最大", "2026-03-17T22:00", "2026-03-18T05:00", ZONE_NPC, 600);
// 夜間3h(22:00〜01:00) = ceil(180/60)*100=300 < 600 → キャップ未適用
test("夜間3h(キャップ未満)", "2026-03-17T22:00", "2026-03-18T01:00", ZONE_NPC, 300);
// 昼間3h(10:00〜13:00) = ceil(180/20)*100=900
test("昼間3h", "2026-03-17T10:00", "2026-03-17T13:00", ZONE_NPC, 900);
// 昼間→夜間またぎ(21:00〜23:00):
//   21:00〜22:00 = 昼間スロット → 60min=ceil(60/20)*100=300
//   22:00〜23:00 = 夜間スロット → 60min=ceil(60/60)*100=100
//   夜間: 100 < 600 → キャップなし
//   total = 300+100=400
test("昼間→夜間またぎ", "2026-03-17T21:00", "2026-03-17T23:00", ZONE_NPC, 400);

console.log("\n【24時間最大2000円: 全時間帯 30分300円】");
// 3h = ceil(180/30)*300=1800 < 2000
test("3h(キャップ未満)", "2026-03-17T10:00", "2026-03-17T13:00", ZONE_24H_ONCE, 1800);
// 4h = ceil(240/30)*300=2400 → cap 2000
test("4h(キャップ超え)", "2026-03-17T10:00", "2026-03-17T14:00", ZONE_24H_ONCE, 2000);
// 25h = per_24h_once なので繰り返しなし → 2000のまま
test("25h(per_24h_once繰り返しなし)", "2026-03-17T10:00", "2026-03-18T11:00", ZONE_24H_ONCE, 2000);

console.log("\n【24時間ごと繰り返し最大1500円: 全時間帯 30分200円】");
// 25h(10:00〜翌11:00):
//   window0(0-86400000ms): 24h=1440min=ceil(1440/30)*200=48*200=9600 → cap 1500
//   window1(86400000+): 1h=60min=ceil(60/30)*200=400 < 1500
//   total = 1500+400 = 1900
test("25h(per_24h_repeat)", "2026-03-17T10:00", "2026-03-18T11:00", ZONE_24H_REPEAT, 1900);
// 48h = 2窓 × 1500 = 3000
test("48h(2窓)", "2026-03-17T10:00", "2026-03-19T10:00", ZONE_24H_REPEAT, 3000);

console.log(`\n合計: ${pass + fail}件 ✅${pass} ❌${fail}`);
