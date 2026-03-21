/**
 * 解析履歴画面
 *
 * 無料プラン: 直近の履歴のみ表示（古い履歴はロック表示）
 * プレミアム: 全履歴にアクセス可能
 */

import { useState, useCallback } from "react";
import { View, Text, TouchableOpacity, ScrollView, Image } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useFocusEffect, useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { ParkingRules } from "@mankai/parking-shared";
import { useAnalytics } from "../../lib/analytics";
import { usePlan } from "../../lib/SubscriptionContext";

type HistoryItem = {
  id: number;
  rules: ParkingRules;
  imageUri: string;
  analyzedAt: string;
};

const FREE_VISIBLE_COUNT = 5;

function formatDate(iso: string) {
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}/${pad(d.getMonth() + 1)}/${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

const cardStyle = {
  shadowColor: "#000",
  shadowOffset: { width: 0, height: 1 },
  shadowOpacity: 0.06,
  shadowRadius: 4,
  elevation: 2,
};

export default function HistoryScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { track } = useAnalytics();
  const { limits } = usePlan();
  const [history, setHistory] = useState<HistoryItem[]>([]);

  useFocusEffect(
    useCallback(() => {
      AsyncStorage.getItem("analysisHistory").then((raw) => {
        try {
          setHistory(raw ? JSON.parse(raw) : []);
        } catch {
          setHistory([]);
        }
      });
    }, [])
  );

  async function handleSelect(item: HistoryItem) {
    track({ name: "history_item_opened" });
    await AsyncStorage.setItem("parkingRules", JSON.stringify(item.rules));
    await AsyncStorage.setItem("uploadedImageUri", item.imageUri ?? "");
    router.push("/result");
  }

  const canAccessAll = limits.canAccessHistory;
  const visibleItems = canAccessAll ? history : history.slice(0, FREE_VISIBLE_COUNT);
  const lockedCount = canAccessAll ? 0 : Math.max(0, history.length - FREE_VISIBLE_COUNT);

  return (
    <View className="flex-1 bg-slate-50" style={{ paddingTop: insets.top + 16 }}>
      <View className="px-5 pb-4 flex-row items-center justify-between">
        <Text className="text-2xl font-bold text-slate-900">履歴</Text>
        {!canAccessAll && history.length > 0 && (
          <View className="rounded-xl bg-slate-100 px-3 py-1.5">
            <Text className="text-xs font-semibold text-slate-500">
              直近{FREE_VISIBLE_COUNT}件まで表示
            </Text>
          </View>
        )}
      </View>

      {history.length === 0 ? (
        <View className="flex-1 items-center justify-center px-8">
          <View className="h-20 w-20 rounded-full bg-slate-100 items-center justify-center mb-5">
            <Ionicons name="time-outline" size={36} color="#94A3B8" />
          </View>
          <Text className="text-base font-semibold text-slate-700 text-center">
            解析履歴がありません
          </Text>
          <Text className="mt-2 text-sm text-slate-400 text-center leading-5">
            看板を解析すると{"\n"}ここに履歴が表示されます
          </Text>
          <TouchableOpacity
            onPress={() => router.push("/upload")}
            activeOpacity={0.85}
            className="mt-6 h-12 px-6 items-center justify-center rounded-2xl bg-blue-600 flex-row gap-2"
            style={{ shadowColor: "#2563EB", shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 5 }}
          >
            <Ionicons name="camera" size={18} color="#fff" />
            <Text className="text-sm font-bold text-white">看板を読み取る</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <ScrollView className="flex-1 px-4" contentContainerStyle={{ gap: 8, paddingBottom: 24 }}>
          {visibleItems.map((item) => (
            <TouchableOpacity
              key={item.id}
              onPress={() => handleSelect(item)}
              activeOpacity={0.75}
              className="flex-row items-center bg-white rounded-2xl p-3 gap-3"
              style={cardStyle}
            >
              {item.imageUri ? (
                <Image
                  source={{ uri: item.imageUri }}
                  className="w-16 h-16 rounded-xl bg-slate-100"
                  resizeMode="cover"
                />
              ) : (
                <View className="w-16 h-16 rounded-xl bg-blue-50 items-center justify-center">
                  <Ionicons name="car" size={28} color="#93C5FD" />
                </View>
              )}
              <View className="flex-1">
                <Text className="text-base font-semibold text-slate-900" numberOfLines={1}>
                  {item.rules.name}
                </Text>
                {(() => {
                  const raw = item.rules as any;
                  const firstMaxPrice = raw.zones?.[0]?.maxPrices?.[0] ?? raw.maxPrice;
                  return firstMaxPrice ? (
                    <View className="flex-row items-center gap-1 mt-0.5">
                      <Ionicons name="pricetag" size={11} color="#2563EB" />
                      <Text className="text-sm text-blue-600">
                        {firstMaxPrice.label ? `${firstMaxPrice.label} ` : ""}最大 ¥{firstMaxPrice.amount.toLocaleString()}
                      </Text>
                    </View>
                  ) : null;
                })()}
                <Text className="text-xs text-slate-400 mt-1">{formatDate(item.analyzedAt)}</Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#CBD5E1" />
            </TouchableOpacity>
          ))}

          {/* ロックされた履歴の表示 */}
          {lockedCount > 0 && (
            <View className="rounded-2xl bg-slate-50 border border-slate-200 p-5 items-center mt-2">
              <View className="h-12 w-12 rounded-full bg-slate-200 items-center justify-center mb-3">
                <Ionicons name="lock-closed" size={24} color="#94A3B8" />
              </View>
              <Text className="text-base font-bold text-slate-700 mb-1">
                他 {lockedCount}件の履歴
              </Text>
              <Text className="text-sm text-slate-400 text-center mb-4">
                プレミアムで全ての履歴にアクセスできます
              </Text>
              <TouchableOpacity
                onPress={() => router.push("/paywall?highlight=premium")}
                className="rounded-xl bg-blue-600 px-6 py-3"
                activeOpacity={0.85}
              >
                <Text className="text-sm font-bold text-white">プレミアムで解放</Text>
              </TouchableOpacity>
            </View>
          )}
        </ScrollView>
      )}
    </View>
  );
}
