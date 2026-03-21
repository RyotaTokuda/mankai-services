import { View, Text, TouchableOpacity, ScrollView } from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { usePlan } from "../../lib/SubscriptionContext";
import { UsageBanner } from "../../components/UsageBanner";

const STEPS = [
  { step: "1", title: "看板を撮影", desc: "駐車場の料金看板をカメラで撮影" },
  { step: "2", title: "AIが自動解析", desc: "料金ルールと最大料金を読み取る" },
  { step: "3", title: "料金を確認", desc: "駐車予定時間の料金をすぐ把握" },
];

export default function HomeScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { state, limits, remainingReads } = usePlan();

  return (
    <ScrollView
      className="flex-1 bg-slate-50"
      contentContainerStyle={{ paddingTop: insets.top + 16, paddingBottom: 32 }}
    >
      {/* ヘッダー */}
      <View className="px-5 pb-6">
        <View className="flex-row items-center justify-between">
          <View>
            <Text className="text-xs font-semibold tracking-widest text-blue-600 uppercase">
              Parking Reader
            </Text>
            <Text className="mt-1 text-2xl font-bold text-slate-900">
              駐車料金リーダー
            </Text>
          </View>
          {/* 残回数バッジ */}
          {state.planType === "free" && (
            <View className="rounded-xl bg-slate-100 px-3 py-1.5">
              <Text className="text-xs font-semibold text-slate-500">
                残り {remainingReads}/{limits.monthlyReadLimit} 回
              </Text>
            </View>
          )}
        </View>
        <Text className="mt-1 text-sm text-slate-500">
          看板を撮るだけで料金をすぐ確認
        </Text>
      </View>

      {/* 上限警告バナー */}
      <UsageBanner />

      {/* メインCTAカード（elevation付き） */}
      <View className="px-4">
        <View
          className="rounded-3xl bg-blue-600 p-6"
          style={{ shadowColor: "#2563EB", shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 12, elevation: 6 }}
        >
          <Text className="text-sm font-medium text-blue-100">現地で迷わない</Text>
          <Text className="mt-1 text-xl font-bold text-white leading-7">
            看板を撮影して{"\n"}料金をすぐ確認
          </Text>
          <TouchableOpacity
            onPress={() => router.push("/upload")}
            activeOpacity={0.85}
            className="mt-5 h-14 w-full items-center justify-center rounded-2xl bg-white flex-row gap-2"
          >
            <Ionicons name="camera" size={20} color="#2563EB" />
            <Text className="text-base font-bold text-blue-600">看板を読み取る</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* 使い方ガイド（情報表示のみ・インタラクティブではない） */}
      <View className="mt-8 px-5">
        <Text className="mb-4 text-xs font-semibold uppercase tracking-widest text-slate-400">
          使い方
        </Text>
        <View className="gap-0">
          {STEPS.map((item, index) => (
            <View key={item.step} className="flex-row gap-4">
              {/* ステップ番号とライン */}
              <View className="items-center" style={{ width: 32 }}>
                <View className="h-8 w-8 rounded-full bg-blue-100 items-center justify-center">
                  <Text className="text-sm font-bold text-blue-600">{item.step}</Text>
                </View>
                {index < STEPS.length - 1 && (
                  <View className="w-0.5 flex-1 bg-blue-100 my-1" style={{ minHeight: 16 }} />
                )}
              </View>
              {/* テキスト */}
              <View className="flex-1 pb-5">
                <Text className="text-sm font-semibold text-slate-800">{item.title}</Text>
                <Text className="mt-0.5 text-xs text-slate-400">{item.desc}</Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      {/* 広告エリア（ダミー） */}
      {!limits.isAdFree && (
        <View className="mx-4 mt-4 rounded-2xl bg-slate-100 border border-dashed border-slate-300 p-4 items-center">
          <Text className="text-xs text-slate-400">広告エリア（実装予定）</Text>
        </View>
      )}
    </ScrollView>
  );
}
