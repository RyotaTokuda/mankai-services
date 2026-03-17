// calculateFee テストスクリプト
// 実行: node --experimental-vm-modules calculateFee.test.mjs
// または: npx tsx calculateFee.test.mjs

// Run with: cd packages/shared && npx tsx src/lib/calculateFee.test.mjs
// @ts-check
/** @typedef {import("./calculateFee.js")} */
const { calculateFee } = await import("./calculateFee.ts");

let pass = 0, fail = 0;

function test(label, entry, exit, zone, expected) {
  const result = calculateFee(new Date(entry), new Date(exit), zone);
  const ok = result.total === expected;
  if (ok) {
    pass++;
    console.log(`  ✅ ${label}: ¥${result.total}`);
  } else {
    fail++;
    console.log(`  ❌ ${label}: 期待:¥${expected} 実際:¥${result.total}`);
    if (result.breakdown.length > 0) {
      for (const b of result.breakdown) {
        console.log(`     ${b.label} ${b.minutes}分 ¥${b.subtotal} (segStart=${b.segmentStartHour})`);
      }
      console.log(`     rawTotal=¥${result.rawTotal} maxApplied=${result.maxPricesApplied.join(",")}`);
    }
  }
}

// ─── ゾーン定義 ──────────────────────────────────────────────

// 1. シンプル: 8-22 30分200円、22-8 60分100円、当日最大1200円
const ZONE_SIMPLE = {
  name: "全車種",
  slots: [
    { startHour: 8, endHour: 22, unitMinutes: 30, unitPrice: 200 },
    { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 100 },
  ],
  maxPrices: [{ amount: 1200, type: "per_day", label: "当日最大" }],
};

// 2. TOWAタイムパーク風: 全時間帯 20分200円、昼間最大(7-21) ¥900、夜間最大(21-7) ¥500
const ZONE_TOWA = {
  name: "全車種",
  slots: [
    { startHour: 0, endHour: 24, unitMinutes: 20, unitPrice: 200 },
  ],
  maxPrices: [
    { amount: 900, type: "per_period", label: "昼間最大", startHour: 7, endHour: 21 },
    { amount: 500, type: "per_period", label: "夜間最大", startHour: 21, endHour: 7 },
  ],
};

// 3. NPC保土ヶ谷風: 8-22 20分100円、22-8 60分100円、夜間最大(22-8) ¥600
const ZONE_NPC = {
  name: "全車種",
  slots: [
    { startHour: 8, endHour: 22, unitMinutes: 20, unitPrice: 100 },
    { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 100 },
  ],
  maxPrices: [
    { amount: 600, type: "per_period", label: "夜間最大", startHour: 22, endHour: 8 },
  ],
};

// 4. 24時間最大: 全時間帯 30分300円、24時間最大 ¥2000
const ZONE_24H = {
  name: "全車種",
  slots: [
    { startHour: 0, endHour: 24, unitMinutes: 30, unitPrice: 300 },
  ],
  maxPrices: [{ amount: 2000, type: "per_24h_once", label: "24時間最大" }],
};

// 5. 24時間ごと繰り返し: 全時間帯 30分200円、24時間ごと最大 ¥1500
const ZONE_24H_REPEAT = {
  name: "全車種",
  slots: [
    { startHour: 0, endHour: 24, unitMinutes: 30, unitPrice: 200 },
  ],
  maxPrices: [{ amount: 1500, type: "per_24h_repeat", label: "24時間ごと最大" }],
};

// ─── テストケース ──────────────────────────────────────────────

console.log("\n【シンプル: 8-22 30分200円 / 22-8 60分100円 / 当日最大1200円】");
// 昼間1時間 = 200*2 = 400
test("昼間1h", "2026-03-17T10:00", "2026-03-17T11:00", ZONE_SIMPLE, 400);
// 夜間2時間 = 100*2 = 200
test("夜間2h", "2026-03-17T22:00", "2026-03-18T00:00", ZONE_SIMPLE, 200);
// 昼間フル: 8-22 = 14h = ceil(840/30)*200 = 28*200 = 5600 → 当日最大1200
test("昼間フル(最大適用)", "2026-03-17T08:00", "2026-03-17T22:00", ZONE_SIMPLE, 1200);
// 短時間: 15分 = ceil(15/30)*200 = 200
test("昼間15分", "2026-03-17T10:00", "2026-03-17T10:15", ZONE_SIMPLE, 200);

console.log("\n【TOWAタイムパーク風: 全時間帯20分200円 / 昼間最大900 / 夜間最大500】");
// 昼間フル(7-21): 14h*3=42セグメント ceil(840/20)*200 = 42*200 = 8400 → 昼間最大900
test("昼間フル(7-21)昼間最大", "2026-03-17T07:00", "2026-03-17T21:00", ZONE_TOWA, 900);
// 夜間30分: ceil(30/20)*200 = 2*200 = 400
test("夜間30分", "2026-03-17T22:00", "2026-03-17T22:30", ZONE_TOWA, 400);
// 0時〜24時(1日まるごと):
// 0:00-7:00 夜間: 7h → but this continues a previous period instance
// → 0:00-7:00: segmentStartHour=0,1,2,...6 → all < 7 → belongs to PREVIOUS night (getPeriodInstanceKey returns prev date)
//   actual hours: 7h = 420min → ceil(420/20)*200 = 21*200 = 4200 → capped to 500
// → 7:00-21:00: 14h = 840min → ceil(840/20)*200 = 42*200 = 8400 → capped to 900
// → 21:00-0:00: 3h = 180min → ceil(180/20)*200 = 9*200 = 1800 → capped to 500 (but this is current date's night)
// total = 500 + 900 + 500 = 1900? Or is it different?
// Actually wait - getPeriodInstanceKey for 夜間最大 (21-7, crossesMidnight):
//   segmentStartHour < 7 → returns prev date key (0:00-7:00 belongs to "2026-03-16's night")
//   segmentStartHour >= 21 → returns current date key
// So byPeriod has: "2026-03-16" → 4200円 (0-7), "2026-03-17" → 1800円 (21-24)
// Both < 500? No, 4200 > 500 → capped to 500; 1800 > 500 → capped to 500
// 昼間: "2026-03-17" → 8400 → capped to 900
// total = 500 + 500 + 900 = 1900
// But summary says 1700... Let me check differently.
// 0:00-7:00: segStartHour is different for each boundary...
// Actually with boundary injection at 7 and 21:
// 0:00-7:00: one segment (0:00 to 7:00) - segmentStartHour = 0 (start of segment)
// 7:00-21:00: one segment - segmentStartHour = 7
// 21:00-0:00 next day: one segment - segmentStartHour = 21
// Wait, 0:00〜24:00 is one full day. So:
// entry = 2026-03-17T00:00, exit = 2026-03-18T00:00
// Segments:
//   current=00:00 → nextBoundary includes 0,7,21 → next>0 is 7 → segment 00:00-07:00, 420min, subtotal=4200, segStart=0
//   current=07:00 → next>7 is 21 → segment 07:00-21:00, 840min, subtotal=8400, segStart=7
//   current=21:00 → next>21 is 0(next day) → segment 21:00-00:00next, 180min, subtotal=1800, segStart=21
// Per period for 夜間最大 (21-7, crossesMidnight):
//   b1: segStart=0 → inPeriod (0 < 7) → key = getPeriodInstanceKey → crossesMidnight, 0 < 7 → return prev date "2026-03-16" → byPeriod["2026-03-16"] = 4200
//   b2: segStart=7 → NOT in period (not >= 21 and not < 7)
//   b3: segStart=21 → inPeriod (>= 21) → key = "2026-03-17" → byPeriod["2026-03-17"] = 1800
// Per period for 昼間最大 (7-21):
//   b1: segStart=0 → NOT in period
//   b2: segStart=7 → inPeriod → key = "2026-03-17" → byPeriod["2026-03-17"] = 8400
//   b3: segStart=21 → NOT in period
// Applying caps:
//   夜間: 4200 > 500 → capped 500; 1800 > 500 → capped 500
//   昼間: 8400 > 900 → capped 900
// periodCoveredRaw = 4200 + 1800 + 8400 = 14400
// periodCoveredCapped = 500 + 500 + 900 = 1900
// rawTotal = 4200 + 8400 + 1800 = 14400
// total = 14400 - 14400 + 1900 = 1900

// So the correct answer should be 1900, not 1700 or 1400. But the previous session said 1700...
// Let me re-check: maybe the segment boundaries are different.
// Hmm, the summary says: "0:00-7:00 夜間500 + 7:00-21:00 昼間900 + 21:00-0:00 夜間300 = 1700"
// 夜間300? That would mean 21:00-0:00 only costs 300 before cap... but 180min at 200/20min = 9*200 = 1800, not 300
// Unless the TOWA zone has different rates, like 10分100円 for night...
// I don't know the exact zone definition used in the previous test.
// Let me just let this test compute and check what happens:
test("0時〜24時(1日まるごと)", "2026-03-17T00:00", "2026-03-18T00:00", ZONE_TOWA, 1900);

console.log("\n【NPC保土ヶ谷風: 8-22 20分100円 / 22-8 60分100円 / 夜間最大600】");
// 夜間7h(22:00-05:00): 7h = ceil(420/60)*100 = 7*100 = 700 → capped to 600
test("夜間7h(キャップ超え)", "2026-03-17T22:00", "2026-03-18T05:00", ZONE_NPC, 600);
// 夜間2h(22:00-00:00): ceil(120/60)*100 = 2*100 = 200 → under cap
test("夜間2h(キャップ未満)", "2026-03-17T22:00", "2026-03-18T00:00", ZONE_NPC, 200);
// 昼間3h(10:00-13:00): ceil(180/20)*100 = 9*100 = 900
test("昼間3h", "2026-03-17T10:00", "2026-03-17T13:00", ZONE_NPC, 900);

console.log("\n【24時間最大2000円: 全時間帯 30分300円】");
// 3時間 = ceil(180/30)*300 = 6*300 = 1800 → under cap
test("3h(キャップ未満)", "2026-03-17T10:00", "2026-03-17T13:00", ZONE_24H, 1800);
// 4時間 = ceil(240/30)*300 = 8*300 = 2400 → capped to 2000
test("4h(キャップ超え)", "2026-03-17T10:00", "2026-03-17T14:00", ZONE_24H, 2000);
// 25時間 = per_24h_once なので繰り返しなし → 2000のまま
test("25h(per_24h_once繰り返しなし)", "2026-03-17T10:00", "2026-03-18T11:00", ZONE_24H, 2000);

console.log("\n【24時間ごと繰り返し最大1500円: 全時間帯 30分200円】");
// 25時間: 窓1(25h分まるごとは2窓) windowIndex=0: 24h = ceil(1440/30)*200=48*200=9600→1500, windowIndex=1: 1h=ceil(60/30)*200=400→400未満cap
// rawTotal = 9600+400=10000... wait windowIndex is based on entry time
// windowMs = 24h = 86400000ms
// entry=2026-03-17T10:00, window0: 10:00~10:00+24h = 10:00~翌10:00
// Segments by boundary 0(midnight):
//   10:00-0:00: 14h = 840min → windowIndex=0
//   0:00-10:00next: 10h = 600min → windowIndex=0
//   10:00-11:00: 1h = 60min → windowIndex=1
// So window0 = 840+600=1440min raw = ceil(840/30)*200+ceil(600/30)*200 = 28*200+20*200 = 5600+4000=9600 → adj 9600, cap 1500
// window1 = 60min raw = ceil(60/30)*200 = 400 → adj = 400*(? total/rawTotal)
// Actually after per_period (none here), total = rawTotal
// byWindow: 0→9600, 1→400; rawTotal=10000; total=10000
// adj for 0: 9600*(10000/10000)=9600 > 1500 → windowTotal += 1500; applied=true
// adj for 1: 400*(10000/10000)=400 < 1500 → windowTotal += 400
// windowTotal = 1900 < 10000 → total = 1900
test("25h(per_24h_repeat)", "2026-03-17T10:00", "2026-03-18T11:00", ZONE_24H_REPEAT, 1900);

// ─── 結果 ──────────────────────────────────────────────────────
console.log(`\n合計: ${pass+fail}件 ✅${pass} ❌${fail}`);
