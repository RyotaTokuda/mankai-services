import { useState, useEffect, useCallback } from "react";
import { View, Text, TouchableOpacity, ScrollView, Linking, Alert } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useFocusEffect } from "expo-router";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";

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

export default function SettingsScreen() {
  const insets = useSafeAreaInsets();
  const version = Constants.expoConfig?.version ?? "0.1.0";
  const [historyLimit, setHistoryLimit] = useState(20);
  const [showLimitPicker, setShowLimitPicker] = useState(false);

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
            <SettingsRow
              label="Googleでログイン"
              onPress={() => Alert.alert("準備中", "ログイン機能は近日公開予定です")}
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
      </View>
    </ScrollView>
  );
}
