import { useState, useEffect, useMemo } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Alert,
} from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  ParkingRules,
  ParkingZone,
  MaxPriceRule,
  TimeSlot,
  NotePriority,
  NoteCategory,
  calculateFee,
} from "@mankai/parking-shared";
import { useAnalytics } from "../lib/analytics";
import { usePlan } from "../lib/SubscriptionContext";
import { FeatureLockCard } from "../components/FeatureLockCard";
import { saveParking, getSavedCount } from "../lib/savedParking";

// ── 旧フォーマット（slots + maxPrice）→ 新フォーマット（zones）へのマイグレーション ──
function migrateRules(raw: any): ParkingRules {
  if (raw?.zones) return raw as ParkingRules;
  // 旧フォーマット対応
  const maxPrices: MaxPriceRule[] = raw?.maxPrice ? [raw.maxPrice] : [];
  return {
    name: raw?.name ?? "駐車場",
    zones: [{ name: "全車種", slots: raw?.slots ?? [], maxPrices }],
    notes: raw?.notes ?? [],
  };
}

const FALLBACK_RULES: ParkingRules = {
  name: "サンプル駐車場",
  zones: [
    {
      name: "普通車",
      slots: [
        { startHour: 8, endHour: 22, unitMinutes: 30, unitPrice: 200 },
        { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 100 },
      ],
      maxPrices: [
        { amount: 1500, type: "per_period", label: "昼間最大", startHour: 8, endHour: 22 },
        { amount: 500, type: "per_period", label: "夜間最大", startHour: 22, endHour: 8 },
      ],
    },
    {
      name: "軽自動車",
      slots: [
        { startHour: 8, endHour: 22, unitMinutes: 30, unitPrice: 150 },
        { startHour: 22, endHour: 8, unitMinutes: 60, unitPrice: 80 },
      ],
      maxPrices: [
        { amount: 1000, type: "per_period", label: "昼間最大", startHour: 8, endHour: 22 },
      ],
    },
  ],
  notes: [
    {
      priority: "high",
      category: "max_price",
      text: "昼間最大・夜間最大はそれぞれの時間帯ごとに適用されます",
    },
  ],
};

const NOTE_ICONS: Record<NoteCategory, string> = {
  max_price: "⚠️", vehicle: "🚗", payment: "💳",
  reentry: "🔄", schedule: "📅", discount: "🎟️",
};
const NOTE_BG: Record<NotePriority, string> = {
  high: "bg-red-50 border-red-200",
  medium: "bg-amber-50 border-amber-200",
  low: "bg-slate-50 border-slate-200",
};
const NOTE_TEXT: Record<NotePriority, string> = {
  high: "text-red-900", medium: "text-amber-900", low: "text-slate-600",
};
const MAX_PRICE_TYPE_LABELS: Record<string, string> = {
  per_day: "当日（0時リセット）",
  per_24h_once: "24時間・1回",
  per_24h_repeat: "24時間ごと",
  per_period: "時間帯ごと",
};
const MAX_PRICE_TYPE_SHORT: Record<string, string> = {
  per_day: "当日", per_24h_once: "24h一回", per_24h_repeat: "24h繰返", per_period: "時間帯",
};

const pad = (n: number) => String(n).padStart(2, "0");
function toTimeStr(d: Date) { return `${pad(d.getHours())}:${pad(d.getMinutes())}`; }
function toDateStr(d: Date) { return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`; }
function roundTo10(d: Date) {
  const m = Math.round(d.getMinutes() / 10) * 10;
  const r = new Date(d);
  if (m >= 60) { r.setHours(r.getHours() + 1, 0, 0, 0); } else { r.setMinutes(m, 0, 0); }
  return r;
}
function combine(date: string, time: string) { return new Date(`${date}T${time}`); }
function clampEntry(eDate: string, eTime: string, xDate: string, xTime: string) {
  const e = combine(eDate, eTime), x = combine(xDate, xTime);
  if (!isNaN(e.getTime()) && !isNaN(x.getTime()) && e >= x) {
    const c = new Date(x.getTime() - 10 * 60000);
    return { date: toDateStr(c), time: toTimeStr(c) };
  }
  return { date: eDate, time: eTime };
}

const cardStyle = {
  shadowColor: "#000",
  shadowOffset: { width: 0, height: 1 },
  shadowOpacity: 0.06,
  shadowRadius: 4,
  elevation: 2,
};

export default function ResultScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { track } = useAnalytics();
  const { limits } = usePlan();

  const now = roundTo10(new Date());
  const later = roundTo10(new Date(Date.now() + 2 * 3600000));

  const [entryDate, setEntryDate] = useState(toDateStr(now));
  const [entryTime, setEntryTime] = useState(toTimeStr(now));
  const [exitDate, setExitDate] = useState(toDateStr(later));
  const [exitTime, setExitTime] = useState(toTimeStr(later));
  const [rules, setRules] = useState<ParkingRules>(FALLBACK_RULES);
  const [selectedZoneIdx, setSelectedZoneIdx] = useState(0);
  const [editingRules, setEditingRules] = useState(false);
  const [isSample, setIsSample] = useState(false);
  const [isSaved, setIsSaved] = useState(false);
  const [imageUri, setImageUri] = useState("");

  useEffect(() => {
    Promise.all([
      AsyncStorage.getItem("parkingRules"),
      AsyncStorage.getItem("uploadedImageUri"),
    ]).then(([stored, uri]) => {
      if (stored) {
        try {
          setRules(migrateRules(JSON.parse(stored)));
        } catch {
          setIsSample(true);
        }
      } else {
        setIsSample(true);
      }
      setImageUri(uri ?? "");
    });
    track({ name: "result_viewed" });
  }, []);

  // ゾーンインデックスがゾーン数を超えていたら0に戻す
  const safeZoneIdx = Math.min(selectedZoneIdx, Math.max(0, rules.zones.length - 1));
  const zone: ParkingZone = rules.zones[safeZoneIdx] ?? { name: "全車種", slots: [], maxPrices: [] };

  function handleExitTimeChange(val: string) {
    setExitTime(val);
    const c = clampEntry(entryDate, entryTime, exitDate, val);
    setEntryDate(c.date); setEntryTime(c.time);
  }
  function handleExitDateChange(val: string) {
    setExitDate(val);
    const c = clampEntry(entryDate, entryTime, val, exitTime);
    setEntryDate(c.date); setEntryTime(c.time);
  }
  function handleEntryTimeChange(val: string) {
    const c = clampEntry(entryDate, val, exitDate, exitTime);
    setEntryDate(c.date); setEntryTime(c.time);
  }
  function handleEntryDateChange(val: string) {
    const c = clampEntry(val, entryTime, exitDate, exitTime);
    setEntryDate(c.date); setEntryTime(c.time);
  }

  // ─── ゾーン編集ヘルパー ───────────────────────────────────────────────
  function updateZone(updater: (z: ParkingZone) => ParkingZone) {
    setRules((prev) => ({
      ...prev,
      zones: prev.zones.map((z, i) => (i === safeZoneIdx ? updater(z) : z)),
    }));
  }

  function updateSlot(slotIdx: number, field: keyof TimeSlot, val: number) {
    updateZone((z) => ({
      ...z,
      slots: z.slots.map((s, i) => (i === slotIdx ? { ...s, [field]: val } : s)),
    }));
  }

  function addSlot() {
    updateZone((z) => ({
      ...z,
      slots: [...z.slots, { startHour: 0, endHour: 24, unitMinutes: 30, unitPrice: 200 }],
    }));
  }

  function removeSlot(slotIdx: number) {
    updateZone((z) => ({ ...z, slots: z.slots.filter((_, i) => i !== slotIdx) }));
  }

  function updateMaxPrice(mpIdx: number, field: keyof MaxPriceRule, val: any) {
    updateZone((z) => ({
      ...z,
      maxPrices: z.maxPrices.map((mp, i) => (i === mpIdx ? { ...mp, [field]: val } : mp)),
    }));
  }

  function addMaxPrice() {
    updateZone((z) => ({
      ...z,
      maxPrices: [...z.maxPrices, { amount: 1000, type: "per_day" as const, label: "最大料金" }],
    }));
  }

  function removeMaxPrice(mpIdx: number) {
    updateZone((z) => ({ ...z, maxPrices: z.maxPrices.filter((_, i) => i !== mpIdx) }));
  }

  // ─── 料金計算 ─────────────────────────────────────────────────────────
  const result = useMemo(() => {
    const e = combine(entryDate, entryTime);
    const x = combine(exitDate, exitTime);
    if (isNaN(e.getTime()) || isNaN(x.getTime())) return null;
    // unitMinutes が 0 や NaN のスロットがあると Infinity/NaN になるため除外
    const safeZone: ParkingZone = {
      ...zone,
      slots: zone.slots.filter((s) => s.unitMinutes > 0 && s.unitPrice >= 0),
    };
    if (safeZone.slots.length === 0) return null;
    return calculateFee(e, x, safeZone);
  }, [entryDate, entryTime, exitDate, exitTime, zone]);

  const sortedNotes = [...rules.notes].sort((a, b) => {
    const o: Record<NotePriority, number> = { high: 0, medium: 1, low: 2 };
    return o[a.priority] - o[b.priority];
  });

  return (
    <View className="flex-1 bg-slate-50" style={{ paddingTop: insets.top }}>
      {/* ヘッダー */}
      <View className="flex-row items-center justify-between px-4 py-3">
        <TouchableOpacity
          onPress={() => router.push("/upload")}
          className="h-11 w-11 items-center justify-center rounded-full bg-white"
          style={cardStyle}
          activeOpacity={0.7}
        >
          <Ionicons name="camera-outline" size={22} color="#475569" />
        </TouchableOpacity>

        <View className="flex-row items-center gap-2">
          <Text
            className="text-lg font-bold text-slate-900"
            numberOfLines={1}
            style={{ maxWidth: 220 }}
          >
            {rules.name}
          </Text>
          {isSample && (
            <View className="rounded-lg bg-slate-100 px-2.5 py-1">
              <Text className="text-sm text-slate-400">サンプル</Text>
            </View>
          )}
        </View>

        <TouchableOpacity
          onPress={() => {
            track({ name: "result_closed" });
            router.replace("/(tabs)");
          }}
          className="h-11 w-11 items-center justify-center rounded-full bg-white"
          style={cardStyle}
          activeOpacity={0.7}
        >
          <Ionicons name="close" size={22} color="#475569" />
        </TouchableOpacity>
      </View>

      <ScrollView
        className="flex-1 px-4"
        contentContainerStyle={{ gap: 12, paddingBottom: 24 }}
      >
        {/* ゾーン（車室）セレクター */}
        {rules.zones.length > 1 && (
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 10, paddingVertical: 2 }}
          >
            {rules.zones.map((z, i) => (
              <TouchableOpacity
                key={i}
                onPress={() => setSelectedZoneIdx(i)}
                activeOpacity={0.75}
                className={`rounded-2xl px-5 py-3 ${
                  i === safeZoneIdx ? "bg-blue-600" : "bg-white"
                }`}
                style={[
                  { minHeight: 44 },
                  i !== safeZoneIdx ? cardStyle : {
                    shadowColor: "#2563EB", shadowOffset: { width: 0, height: 2 },
                    shadowOpacity: 0.25, shadowRadius: 6, elevation: 4,
                  },
                ]}
              >
                <Text
                  className={`text-base font-semibold ${
                    i === safeZoneIdx ? "text-white" : "text-slate-600"
                  }`}
                >
                  {z.name}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        )}

        {/* 時間入力 */}
        <View className="rounded-2xl bg-white p-5 gap-4" style={cardStyle}>
          <Text className="text-sm font-semibold uppercase tracking-widest text-slate-400">
            駐車予定
          </Text>
          {[
            {
              label: "入庫",
              date: entryDate,
              time: entryTime,
              onDateChange: handleEntryDateChange,
              onTimeChange: handleEntryTimeChange,
            },
            {
              label: "出庫（予定）",
              date: exitDate,
              time: exitTime,
              onDateChange: handleExitDateChange,
              onTimeChange: handleExitTimeChange,
            },
          ].map((row) => (
            <View key={row.label}>
              <Text className="mb-2 text-base font-medium text-slate-500">{row.label}</Text>
              <View className="flex-row gap-3">
                <TextInput
                  value={row.date}
                  onChangeText={row.onDateChange}
                  className="flex-1 rounded-xl border border-slate-200 px-4 py-3 text-lg text-slate-900 bg-slate-50"
                  placeholder="YYYY-MM-DD"
                  style={{ minHeight: 48 }}
                />
                <TextInput
                  value={row.time}
                  onChangeText={row.onTimeChange}
                  className="w-28 rounded-xl border border-slate-200 px-4 py-3 text-lg text-slate-900 bg-slate-50"
                  placeholder="HH:MM"
                  style={{ minHeight: 48 }}
                />
              </View>
            </View>
          ))}
        </View>

        {/* 料金表示 */}
        {result && (
          <View
            className="rounded-3xl bg-blue-600 p-6"
            style={{
              shadowColor: "#2563EB",
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.3,
              shadowRadius: 12,
              elevation: 6,
            }}
          >
            <Text className="text-base font-medium text-blue-100">想定料金</Text>
            <Text className="mt-1 text-5xl font-bold text-white">
              ¥{result.total.toLocaleString()}
            </Text>

            {/* 適用された最大料金 */}
            {result.maxPricesApplied.length > 0 && (
              <View className="mt-3 flex-row flex-wrap gap-2">
                {result.maxPricesApplied.map((lbl, i) => (
                  <View key={i} className="self-start rounded-xl bg-white/20 px-3.5 py-2">
                    <Text className="text-sm font-semibold text-white">{lbl} 適用</Text>
                  </View>
                ))}
              </View>
            )}

            {/* 内訳 */}
            {result.breakdown.length > 0 && (
              <View className="mt-4 gap-2 border-t border-white/20 pt-4">
                <Text className="text-sm text-blue-200 mb-0.5">内訳</Text>
                {result.breakdown.map((b, i) => (
                  <View key={i} className="flex-row justify-between">
                    <Text className="text-base text-blue-100">
                      {b.label}（{b.minutes}分）
                    </Text>
                    <Text className="text-base font-semibold text-white">
                      ¥{b.subtotal.toLocaleString()}
                    </Text>
                  </View>
                ))}
                {result.rawTotal !== result.total && (
                  <View className="flex-row justify-between border-t border-white/10 pt-2 mt-1">
                    <Text className="text-sm text-blue-200">最大料金適用前</Text>
                    <Text className="text-sm text-blue-200 line-through">
                      ¥{result.rawTotal.toLocaleString()}
                    </Text>
                  </View>
                )}
              </View>
            )}
          </View>
        )}

        {/* 料金ルール */}
        <View className="rounded-2xl bg-white p-5" style={cardStyle}>
          <View className="flex-row items-center justify-between mb-4">
            <Text className="text-sm font-semibold uppercase tracking-widest text-slate-400">
              料金ルール{rules.zones.length > 1 ? `（${zone.name}）` : ""}
            </Text>
            {/* 鉛筆アイコン / チェックマークアイコン */}
            <TouchableOpacity
              onPress={() => setEditingRules((v) => !v)}
              className={`h-11 w-11 items-center justify-center rounded-full ${
                editingRules ? "bg-blue-600" : "bg-slate-100"
              }`}
              activeOpacity={0.7}
            >
              <Ionicons
                name={editingRules ? "checkmark" : "create-outline"}
                size={22}
                color={editingRules ? "#fff" : "#475569"}
              />
            </TouchableOpacity>
          </View>

          {editingRules ? (
            // ─── 編集モード ─────────────────────────────────────────────
            <View className="gap-5">
              {/* 時間帯ごとの料金 */}
              <View className="gap-3">
                <Text className="text-sm font-semibold text-slate-500">時間帯料金</Text>
                {zone.slots.map((slot, i) => (
                  <View key={i} className="rounded-2xl bg-slate-50 p-4 gap-3">
                    <View className="flex-row items-center justify-between">
                      <Text className="text-sm font-medium text-slate-400">時間帯 {i + 1}</Text>
                      <TouchableOpacity
                        onPress={() => removeSlot(i)}
                        className="h-10 w-10 items-center justify-center rounded-full bg-red-50"
                        activeOpacity={0.7}
                      >
                        <Ionicons name="trash-outline" size={18} color="#EF4444" />
                      </TouchableOpacity>
                    </View>
                    {/* 開始〜終了 */}
                    <View className="flex-row items-center gap-2">
                      <TextInput
                        value={String(slot.startHour)}
                        onChangeText={(v) => updateSlot(i, "startHour", Number(v))}
                        keyboardType="number-pad"
                        className="w-16 rounded-xl border border-slate-200 bg-white px-3 py-3 text-center text-base text-slate-900"
                        style={{ minHeight: 44 }}
                      />
                      <Text className="text-base text-slate-400">:00 〜</Text>
                      <TextInput
                        value={String(slot.endHour)}
                        onChangeText={(v) => updateSlot(i, "endHour", Number(v))}
                        keyboardType="number-pad"
                        className="w-16 rounded-xl border border-slate-200 bg-white px-3 py-3 text-center text-base text-slate-900"
                        style={{ minHeight: 44 }}
                      />
                      <Text className="text-base text-slate-400">:00</Text>
                    </View>
                    {/* 単価 */}
                    <View className="flex-row items-center gap-2">
                      <Text className="text-base text-slate-400">¥</Text>
                      <TextInput
                        value={String(slot.unitPrice)}
                        onChangeText={(v) => updateSlot(i, "unitPrice", Number(v))}
                        keyboardType="number-pad"
                        className="w-24 rounded-xl border border-slate-200 bg-white px-3 py-3 text-base text-slate-900"
                        style={{ minHeight: 44 }}
                      />
                      <Text className="text-base text-slate-400">/</Text>
                      <TextInput
                        value={String(slot.unitMinutes)}
                        onChangeText={(v) => updateSlot(i, "unitMinutes", Number(v))}
                        keyboardType="number-pad"
                        className="w-20 rounded-xl border border-slate-200 bg-white px-3 py-3 text-base text-slate-900"
                        style={{ minHeight: 44 }}
                      />
                      <Text className="text-base text-slate-400">分</Text>
                    </View>
                  </View>
                ))}
                <TouchableOpacity
                  onPress={addSlot}
                  className="flex-row items-center justify-center gap-2 rounded-2xl border border-dashed border-slate-300"
                  style={{ minHeight: 48 }}
                  activeOpacity={0.7}
                >
                  <Ionicons name="add" size={20} color="#94A3B8" />
                  <Text className="text-base text-slate-400">時間帯を追加</Text>
                </TouchableOpacity>
              </View>

              {/* 最大料金 */}
              <View className="gap-3">
                <Text className="text-sm font-semibold text-slate-500">最大料金</Text>
                {zone.maxPrices.map((mp, i) => (
                  <View key={i} className="rounded-2xl bg-slate-50 p-4 gap-3">
                    <View className="flex-row items-center justify-between">
                      <TextInput
                        value={mp.label ?? ""}
                        onChangeText={(v) => updateMaxPrice(i, "label", v)}
                        placeholder="ラベル（例: 昼間最大）"
                        className="flex-1 rounded-xl border border-slate-200 bg-white px-3 py-3 text-base text-slate-900 mr-2"
                        style={{ minHeight: 44 }}
                      />
                      <TouchableOpacity
                        onPress={() => removeMaxPrice(i)}
                        className="h-10 w-10 items-center justify-center rounded-full bg-red-50"
                        activeOpacity={0.7}
                      >
                        <Ionicons name="trash-outline" size={18} color="#EF4444" />
                      </TouchableOpacity>
                    </View>
                    {/* 金額 */}
                    <View className="flex-row items-center gap-2">
                      <Text className="text-base text-slate-400">¥</Text>
                      <TextInput
                        value={String(mp.amount)}
                        onChangeText={(v) => updateMaxPrice(i, "amount", Number(v))}
                        keyboardType="number-pad"
                        className="w-28 rounded-xl border border-slate-200 bg-white px-3 py-3 text-base text-slate-900"
                        style={{ minHeight: 44 }}
                      />
                    </View>
                    {/* タイプ */}
                    <View className="flex-row gap-2 flex-wrap">
                      {(["per_day", "per_24h_once", "per_24h_repeat", "per_period"] as const).map((t) => (
                        <TouchableOpacity
                          key={t}
                          onPress={() => updateMaxPrice(i, "type", t)}
                          className={`rounded-xl px-3 py-2.5 ${
                            mp.type === t ? "bg-blue-600" : "bg-white border border-slate-200"
                          }`}
                          style={{ minHeight: 40 }}
                        >
                          <Text
                            className={`text-sm font-semibold ${
                              mp.type === t ? "text-white" : "text-slate-600"
                            }`}
                          >
                            {MAX_PRICE_TYPE_SHORT[t]}
                          </Text>
                        </TouchableOpacity>
                      ))}
                    </View>
                    {/* per_period のみ: 対象時間帯 */}
                    {mp.type === "per_period" && (
                      <View className="flex-row items-center gap-2">
                        <Text className="text-sm text-slate-400">対象時間帯</Text>
                        <TextInput
                          value={String(mp.startHour ?? "")}
                          onChangeText={(v) => updateMaxPrice(i, "startHour", Number(v))}
                          keyboardType="number-pad"
                          placeholder="開始h"
                          className="w-16 rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-center text-base text-slate-900"
                          style={{ minHeight: 44 }}
                        />
                        <Text className="text-base text-slate-400">〜</Text>
                        <TextInput
                          value={String(mp.endHour ?? "")}
                          onChangeText={(v) => updateMaxPrice(i, "endHour", Number(v))}
                          keyboardType="number-pad"
                          placeholder="終了h"
                          className="w-16 rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-center text-base text-slate-900"
                          style={{ minHeight: 44 }}
                        />
                      </View>
                    )}
                  </View>
                ))}
                <TouchableOpacity
                  onPress={addMaxPrice}
                  className="flex-row items-center justify-center gap-2 rounded-2xl border border-dashed border-slate-300"
                  style={{ minHeight: 48 }}
                  activeOpacity={0.7}
                >
                  <Ionicons name="add" size={20} color="#94A3B8" />
                  <Text className="text-base text-slate-400">最大料金を追加</Text>
                </TouchableOpacity>
              </View>
            </View>
          ) : (
            // ─── 表示モード ─────────────────────────────────────────────
            <View className="gap-3">
              {zone.slots.map((slot, i) => (
                <View key={i} className="flex-row justify-between items-center" style={{ minHeight: 44 }}>
                  <Text className="text-base text-slate-500">
                    {slot.startHour}:00〜{slot.endHour === 24 ? "24:00" : `${slot.endHour}:00`}
                  </Text>
                  <Text className="text-lg font-semibold text-slate-900">
                    ¥{slot.unitPrice.toLocaleString()} / {slot.unitMinutes}分
                  </Text>
                </View>
              ))}

              {zone.maxPrices.length > 0 && (
                <View className="gap-2 border-t border-slate-100 pt-3 mt-1">
                  {zone.maxPrices.map((mp, i) => {
                    // per_period: 対象時間帯を表示（例: 8:00〜22:00）
                    const periodRange = mp.type === "per_period" && mp.startHour != null && mp.endHour != null
                      ? `${mp.startHour}:00〜${mp.endHour === 24 ? "24:00" : `${mp.endHour}:00`}`
                      : null;
                    return (
                      <View key={i} className="flex-row justify-between items-center" style={{ minHeight: 44 }}>
                        <View className="flex-1 mr-3">
                          <View className="flex-row items-center gap-2 flex-wrap">
                            {mp.label && (
                              <Text className="text-base text-slate-600 font-medium">{mp.label}</Text>
                            )}
                            <View className="rounded-lg bg-blue-50 px-2 py-1">
                              <Text className="text-sm text-blue-500 font-medium">
                                {MAX_PRICE_TYPE_LABELS[mp.type] ?? mp.type}
                              </Text>
                            </View>
                          </View>
                          {periodRange && (
                            <Text className="text-sm text-slate-400 mt-0.5">
                              対象: {periodRange}
                            </Text>
                          )}
                        </View>
                        <Text className="text-lg font-semibold text-blue-600">
                          ¥{mp.amount.toLocaleString()}
                        </Text>
                      </View>
                    );
                  })}
                </View>
              )}
            </View>
          )}
        </View>

        {/* 保存・比較・詳細シミュレーションの有料機能セクション */}
        <View className="gap-3">
          {/* 保存ボタン */}
          <TouchableOpacity
            onPress={async () => {
              if (isSaved) return;
              const count = await getSavedCount();
              if (count >= limits.saveLimit) {
                track({ name: "parking_save_limit_hit", properties: { limit: limits.saveLimit } });
                Alert.alert(
                  "保存上限に達しています",
                  `現在のプランでは${limits.saveLimit}件まで保存できます。\nプランをアップグレードすると、より多くの駐車場を保存できます。`,
                  [
                    { text: "閉じる", style: "cancel" },
                    { text: "プランを見る", onPress: () => router.push("/paywall?highlight=premium") },
                  ],
                );
                return;
              }
              await saveParking(rules, imageUri);
              track({ name: "parking_saved", properties: { count: count + 1 } });
              setIsSaved(true);
            }}
            className={`rounded-2xl p-4 flex-row items-center justify-between ${
              isSaved ? "bg-green-50 border border-green-200" : "bg-white"
            }`}
            style={isSaved ? {} : cardStyle}
            activeOpacity={isSaved ? 1 : 0.75}
          >
            <View className="flex-row items-center gap-3">
              <View className={`h-10 w-10 rounded-full items-center justify-center ${
                isSaved ? "bg-green-100" : "bg-blue-50"
              }`}>
                <Ionicons
                  name={isSaved ? "checkmark-circle" : "bookmark-outline"}
                  size={20}
                  color={isSaved ? "#22C55E" : "#2563EB"}
                />
              </View>
              <View>
                <Text className={`text-base font-medium ${isSaved ? "text-green-800" : "text-slate-800"}`}>
                  {isSaved ? "保存しました" : "この駐車場を保存"}
                </Text>
                <Text className="text-xs text-slate-400">
                  {isSaved ? "「保存済み」タブで確認できます" : `次回すぐ見返せます（${limits.saveLimit}件まで）`}
                </Text>
              </View>
            </View>
          </TouchableOpacity>

          {/* 比較ボタン */}
          <TouchableOpacity
            onPress={() => {
              if (limits.compareLimit <= 2) {
                router.push("/paywall?highlight=pass_24h");
              } else {
                router.push("/compare");
              }
            }}
            className="rounded-2xl bg-white p-4 flex-row items-center justify-between"
            style={cardStyle}
            activeOpacity={0.75}
          >
            <View className="flex-row items-center gap-3">
              <View className="h-10 w-10 rounded-full bg-blue-50 items-center justify-center">
                <Ionicons name="git-compare-outline" size={20} color="#2563EB" />
              </View>
              <View>
                <Text className="text-base font-medium text-slate-800">他の駐車場と比較</Text>
                <Text className="text-xs text-slate-400">
                  {limits.compareLimit <= 2
                    ? "複数候補をその場で比較できます"
                    : `${limits.compareLimit}件まで比較可能`}
                </Text>
              </View>
            </View>
            {limits.compareLimit <= 2 && (
              <View className="rounded-lg bg-amber-100 px-2 py-1">
                <Text className="text-[10px] font-bold text-amber-600">PRO</Text>
              </View>
            )}
          </TouchableOpacity>

          {/* 詳細シミュレーション */}
          {limits.canUseAdvancedSimulation ? (
            <TouchableOpacity
              onPress={() => router.push("/simulation")}
              className="rounded-2xl bg-white p-5"
              style={cardStyle}
              activeOpacity={0.75}
            >
              <View className="flex-row items-center justify-between mb-3">
                <Text className="text-sm font-semibold uppercase tracking-widest text-slate-400">
                  詳細シミュレーション
                </Text>
                <Ionicons name="chevron-forward" size={18} color="#94A3B8" />
              </View>
              <View className="gap-2">
                <View className="flex-row items-center gap-2">
                  <Ionicons name="time-outline" size={16} color="#2563EB" />
                  <Text className="text-sm text-slate-600">
                    あと何分で料金が加算されるか
                  </Text>
                </View>
                <View className="flex-row items-center gap-2">
                  <Ionicons name="trending-up-outline" size={16} color="#2563EB" />
                  <Text className="text-sm text-slate-600">
                    最大料金到達タイミング
                  </Text>
                </View>
                <View className="flex-row items-center gap-2">
                  <Ionicons name="moon-outline" size={16} color="#2563EB" />
                  <Text className="text-sm text-slate-600">
                    昼夜跨ぎの料金変動
                  </Text>
                </View>
              </View>
            </TouchableOpacity>
          ) : (
            <FeatureLockCard
              feature="詳細シミュレーション"
              message="あと何分で料金が上がるか確認"
              subMessage="最大料金到達タイミングも分かります"
              unlockWith="both"
            />
          )}
        </View>

        {/* 広告エリア（ダミー） */}
        {!limits.isAdFree && (
          <View className="rounded-2xl bg-slate-100 border border-dashed border-slate-300 p-4 items-center">
            <Text className="text-xs text-slate-400">広告エリア（実装予定）</Text>
          </View>
        )}

        {/* 注意事項 */}
        {sortedNotes.length > 0 && (
          <View className="gap-2.5">
            <Text className="text-sm font-semibold uppercase tracking-widest text-slate-400 px-1">
              注意事項
            </Text>
            {sortedNotes.map((note, i) => (
              <View key={i} className={`rounded-2xl border px-4 py-3.5 ${NOTE_BG[note.priority]}`}>
                <Text className={`text-base leading-6 ${NOTE_TEXT[note.priority]}`}>
                  {NOTE_ICONS[note.category]} {note.text}
                </Text>
              </View>
            ))}
          </View>
        )}

        <TouchableOpacity
          onPress={() => router.push("/upload")}
          className="w-full items-center justify-center rounded-2xl bg-white flex-row gap-2"
          style={[cardStyle, { minHeight: 48 }]}
          activeOpacity={0.75}
        >
          <Ionicons name="camera-outline" size={20} color="#475569" />
          <Text className="text-base font-semibold text-slate-700">別の看板を読み取る</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}
