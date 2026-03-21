import { useState, useEffect, useCallback } from "react";
import { View, Text, TouchableOpacity, ScrollView, Linking, Alert } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useFocusEffect, useRouter } from "expo-router";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";
import { usePlan } from "../../lib/SubscriptionContext";
import { useAuth } from "../../lib/AuthContext";
import { PLAN_INFO, type PlanType } from "../../lib/subscription";

const FEEDBACK_URL = "mailto:mankaisoftware.info@gmail.com?subject=【駐車料金リーダー】フィードバック";
const PRIVACY_URL = "https://mankai-software.vercel.app/privacy";
const TERMS_URL = "https://mankai-software.vercel.app/terms";

const HISTORY_LIMIT_KEY = "historyLimit";

const LIMIT_OPTIONS = [
  { value: 20, label: "20件", premium: false },
  { value: 100, label: "100件", premium: true },
  { value: 300, label: "300件", premium: true },
  { value: 1000, label: "1,000件", premium: true },
] as const;

function SectionHeader({ title }: { title: string }) {
  return (
    <Text className="mb-2 px-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
      {title}
    </Text>
  );
}

function SettingsRow({
  label,
  onPress,
  value,
  chevron = true,
}: {
  label: string;
  onPress?: () => void;
  value?: string;
  chevron?: boolean;
}) {
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={onPress ? 0.7 : 1}
      className="flex-row items-center justify-between px-4 py-3.5"
    >
      <Text className="text-sm font-medium text-slate-800">{label}</Text>
      {value ? (
        <Text className="text-sm text-slate-400">{value}</Text>
      ) : onPress && chevron ? (
        <Ionicons name="chevron-forward" size={16} color="#94A3B8" />
      ) : null}
    </TouchableOpacity>
  );
}

function Divider() {
  return <View className="h-px bg-slate-100 mx-4" />;
}

const DEBUG_PLANS: { label: string; planType: PlanType; expired?: boolean }[] = [
  { label: "無料", planType: "free" },
  { label: "24hパス", planType: "pass_24h" },
  { label: "24hパス(期限切)", planType: "pass_24h", expired: true },
  { label: "プレミアム", planType: "premium" },
  { label: "プレミアム(期限切)", planType: "premium", expired: true },
];

export default function SettingsScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const version = Constants.expoConfig?.version ?? "0.1.0";
  const [historyLimit, setHistoryLimit] = useState(20);
  const [showLimitPicker, setShowLimitPicker] = useState(false);
  const { user, loading: authLoading, signInWithGoogle, signOut } = useAuth();
  const { state, restorePurchase, debugSetPlan, debugResetCount } = usePlan();

  useFocusEffect(
    useCallback(() => {
      AsyncStorage.getItem(HISTORY_LIMIT_KEY).then((val) => {
        const n = Number(val);
        if (val && !isNaN(n)) setHistoryLimit(n);
      });
    }, [])
  );

  async function openUrl(url: string) {
    const supported = await Linking.canOpenURL(url);
    if (supported) {
      await Linking.openURL(url);
    } else {
      Alert.alert("エラー", "URLを開けませんでした");
    }
  }

  async function selectLimit(value: number, premium: boolean) {
    if (premium) {
      Alert.alert(
        "サブスクリプション限定",
        "より多くの履歴を保存するにはサブスクリプションが必要です。\n近日公開予定です。",
        [{ text: "OK" }]
      );
      return;
    }
    setHistoryLimit(value);
    await AsyncStorage.setItem(HISTORY_LIMIT_KEY, String(value));
    setShowLimitPicker(false);
  }

  return (
    <ScrollView
      className="flex-1 bg-slate-50"
      contentContainerStyle={{ paddingTop: insets.top + 16, paddingBottom: 32 }}
    >
      <View className="px-5 pb-6">
        <Text className="text-2xl font-bold text-slate-900">設定</Text>
      </View>

      <View className="px-4 gap-5">
        {/* アカウント */}
        <View>
          <SectionHeader title="アカウント" />
          <View
            className="rounded-2xl bg-white overflow-hidden"
            style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
          >
            {user ? (
              <>
                <View className="px-4 py-3.5">
                  <View className="flex-row items-center gap-3">
                    <View className="h-10 w-10 rounded-full bg-blue-100 items-center justify-center">
                      <Text className="text-base font-bold text-blue-600">
                        {(user.user_metadata?.full_name ?? user.email ?? "U").charAt(0).toUpperCase()}
                      </Text>
                    </View>
                    <View className="flex-1">
                      {user.user_metadata?.full_name && (
                        <Text className="text-sm font-medium text-slate-800">
                          {user.user_metadata.full_name}
                        </Text>
                      )}
                      <Text className="text-xs text-slate-400">{user.email}</Text>
                    </View>
                  </View>
                </View>
                <Divider />
                <SettingsRow
                  label="ログアウト"
                  onPress={() =>
                    Alert.alert("ログアウト", "ログアウトしますか？", [
                      { text: "キャンセル", style: "cancel" },
                      { text: "ログアウト", style: "destructive", onPress: signOut },
                    ])
                  }
                />
              </>
            ) : (
              <SettingsRow
                label="Googleでログイン"
                onPress={signInWithGoogle}
              />
            )}
          </View>
        </View>

        {/* プラン */}
        <View>
          <SectionHeader title="プラン" />
          <View
            className="rounded-2xl bg-white overflow-hidden"
            style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
          >
            <View className="px-4 py-3.5">
              <View className="flex-row items-center justify-between">
                <Text className="text-sm font-medium text-slate-800">現在のプラン</Text>
                <View className={`rounded-lg px-2.5 py-1 ${
                  state.planType === "free" ? "bg-slate-100" :
                  state.planStatus === "expired" ? "bg-red-100" : "bg-blue-100"
                }`}>
                  <Text className={`text-xs font-bold ${
                    state.planType === "free" ? "text-slate-500" :
                    state.planStatus === "expired" ? "text-red-600" : "text-blue-600"
                  }`}>
                    {PLAN_INFO[state.planType].name}
                    {state.planStatus === "expired" ? "（期限切れ）" : ""}
                  </Text>
                </View>
              </View>
            </View>
            <Divider />
            <SettingsRow
              label="プランを変更"
              onPress={() => router.push("/paywall")}
            />
            <Divider />
            <SettingsRow
              label="購入を復元"
              onPress={async () => {
                const restored = await restorePurchase();
                Alert.alert(
                  restored ? "復元しました" : "復元する購入がありません",
                  restored
                    ? "有効なプランが復元されました。"
                    : "App Store / Google Play に有効な購入が見つかりませんでした。",
                );
              }}
            />
          </View>
        </View>

        {/* 履歴 */}
        <View>
          <SectionHeader title="履歴" />
          <View
            className="rounded-2xl bg-white overflow-hidden"
            style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
          >
            <TouchableOpacity
              onPress={() => setShowLimitPicker(v => !v)}
              activeOpacity={0.7}
              className="flex-row items-center justify-between px-4 py-3.5"
            >
              <Text className="text-sm font-medium text-slate-800">保存件数の上限</Text>
              <View className="flex-row items-center gap-1">
                <Text className="text-sm text-slate-400">{historyLimit}件</Text>
                <Ionicons
                  name={showLimitPicker ? "chevron-up" : "chevron-down"}
                  size={16}
                  color="#94A3B8"
                />
              </View>
            </TouchableOpacity>

            {showLimitPicker && (
              <>
                <Divider />
                <View className="px-4 py-3 gap-2">
                  <Text className="text-xs text-slate-400 mb-1">
                    無料プランでは20件まで保存できます
                  </Text>
                  <View className="flex-row flex-wrap gap-2">
                    {LIMIT_OPTIONS.map((opt) => {
                      const isSelected = historyLimit === opt.value;
                      return (
                        <TouchableOpacity
                          key={opt.value}
                          onPress={() => selectLimit(opt.value, opt.premium)}
                          activeOpacity={0.75}
                          className={`flex-row items-center gap-1.5 rounded-xl px-4 py-2 ${
                            isSelected
                              ? "bg-blue-600"
                              : opt.premium
                              ? "bg-slate-100"
                              : "bg-slate-100"
                          }`}
                        >
                          {opt.premium && (
                            <Ionicons
                              name="lock-closed"
                              size={12}
                              color={isSelected ? "#fff" : "#94A3B8"}
                            />
                          )}
                          <Text
                            className={`text-sm font-semibold ${
                              isSelected ? "text-white" : opt.premium ? "text-slate-400" : "text-slate-700"
                            }`}
                          >
                            {opt.label}
                          </Text>
                          {opt.premium && !isSelected && (
                            <View className="rounded bg-amber-100 px-1">
                              <Text className="text-[10px] font-bold text-amber-600">PRO</Text>
                            </View>
                          )}
                        </TouchableOpacity>
                      );
                    })}
                  </View>
                </View>
              </>
            )}
          </View>
        </View>

        {/* サポート */}
        <View>
          <SectionHeader title="サポート" />
          <View
            className="rounded-2xl bg-white overflow-hidden"
            style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
          >
            <SettingsRow
              label="フィードバックを送る"
              onPress={() => openUrl(FEEDBACK_URL)}
            />
            <Divider />
            <SettingsRow
              label="プライバシーポリシー"
              onPress={() => openUrl(PRIVACY_URL)}
            />
            <Divider />
            <SettingsRow
              label="利用規約"
              onPress={() => openUrl(TERMS_URL)}
            />
          </View>
        </View>

        {/* アプリ情報 */}
        <View>
          <SectionHeader title="アプリ情報" />
          <View
            className="rounded-2xl bg-white overflow-hidden"
            style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
          >
            <SettingsRow label="バージョン" value={version} chevron={false} />
          </View>
        </View>

        {/* 課金デバッグ（開発用） */}
        {__DEV__ && (
          <View>
            <SectionHeader title="課金デバッグ（開発用）" />
            <View
              className="rounded-2xl bg-white overflow-hidden p-4 gap-3"
              style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
            >
              {/* 現在の状態 */}
              <View className="rounded-xl bg-slate-50 p-3">
                <Text className="text-xs font-semibold text-slate-400 mb-1">現在のプラン</Text>
                <Text className="text-sm font-bold text-slate-800">
                  {PLAN_INFO[state.planType].name}
                  {state.planStatus === "expired" ? "（期限切れ）" : ""}
                </Text>
                <Text className="text-xs text-slate-500 mt-0.5">
                  読取: {state.monthlyReadCount}回使用
                  {state.planExpiresAt ? ` | 期限: ${new Date(state.planExpiresAt).toLocaleString("ja-JP")}` : ""}
                </Text>
              </View>

              {/* プラン切替ボタン */}
              <Text className="text-xs font-semibold text-slate-400">プランを切替</Text>
              <View className="flex-row flex-wrap gap-2">
                {DEBUG_PLANS.map((dp) => {
                  const isActive = state.planType === dp.planType &&
                    (dp.expired ? state.planStatus === "expired" : state.planStatus === "active");
                  return (
                    <TouchableOpacity
                      key={dp.label}
                      onPress={() => debugSetPlan(dp.planType, dp.expired)}
                      className={`rounded-xl px-3 py-2 ${isActive ? "bg-blue-600" : "bg-slate-100"}`}
                      activeOpacity={0.75}
                    >
                      <Text className={`text-sm font-semibold ${isActive ? "text-white" : "text-slate-600"}`}>
                        {dp.label}
                      </Text>
                    </TouchableOpacity>
                  );
                })}
              </View>

              {/* 読取カウントリセット */}
              <TouchableOpacity
                onPress={debugResetCount}
                className="rounded-xl bg-red-50 border border-red-200 px-4 py-2.5 items-center"
                activeOpacity={0.75}
              >
                <Text className="text-sm font-semibold text-red-600">読取カウントをリセット</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}
      </View>
    </ScrollView>
  );
}
