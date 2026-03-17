import { useState, useRef, useEffect } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  Animated,
  ScrollView,
  Alert,
} from "react-native";
import * as ImagePicker from "expo-image-picker";
import * as ImageManipulator from "expo-image-manipulator";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { ParkingRules, MaxPriceRule } from "@mankai/parking-shared";
import { useAnalytics } from "../lib/analytics";

// 旧フォーマット（slots + maxPrice）→ 新フォーマット（zones）へのマイグレーション
function migrateRules(raw: any): ParkingRules {
  if (raw?.zones) return raw as ParkingRules;
  const maxPrices: MaxPriceRule[] = raw?.maxPrice ? [raw.maxPrice] : [];
  return {
    name: raw?.name ?? "駐車場",
    zones: [{ name: "全車種", slots: raw?.slots ?? [], maxPrices }],
    notes: raw?.notes ?? [],
  };
}

// 本番環境ではVercelのURLに差し替える
const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? "http://localhost:3000";
const MAX_FILE_BYTES = 10 * 1024 * 1024;

function getUserErrorMessage(status: number, serverMsg: string): string {
  switch (status) {
    case 503:
      return "現在サービスが混み合っています。\nしばらくしてから再度お試しください。";
    case 429:
      return "リクエストが集中しています。\n少し時間を空けてから再度お試しください。";
    case 413:
      return "画像サイズが大きすぎます。\n別の画像を選んでください。";
    case 500:
      if (serverMsg.includes("JSON")) {
        return "看板の読み取りに失敗しました。\n別の角度から撮り直してみてください。";
      }
      return "サーバーでエラーが発生しました。\nしばらくしてから再度お試しください。";
    case 400:
      return "画像データに問題があります。\n別の画像を選んでください。";
    default:
      return serverMsg || "解析に失敗しました。\n再度お試しください。";
  }
}

type AnalyzeState = "idle" | "loading" | "error";

const PROGRESS_MESSAGES = [
  "画像を送信中...",
  "看板を読み取り中...",
  "料金ルールを解析中...",
  "結果を整理中...",
];

export default function UploadScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const abortRef = useRef<AbortController | null>(null);
  const { track } = useAnalytics();

  const [imageUri, setImageUri] = useState<string | null>(null);
  const [imageBase64, setImageBase64] = useState<string | null>(null);
  const [analyzeState, setAnalyzeState] = useState<AnalyzeState>("idle");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // プログレスバー
  const progressAnim = useRef(new Animated.Value(0)).current;
  const [progressMsg, setProgressMsg] = useState(PROGRESS_MESSAGES[0]);

  useEffect(() => {
    if (analyzeState !== "loading") {
      progressAnim.setValue(0);
      setProgressMsg(PROGRESS_MESSAGES[0]);
      return;
    }
    // 0→90% を 20 秒かけて進行（API 完了で一気に 100%）
    Animated.timing(progressAnim, {
      toValue: 0.9,
      duration: 20000,
      useNativeDriver: false,
    }).start();

    // メッセージを段階的に切り替え
    const timers = PROGRESS_MESSAGES.slice(1).map((msg, i) =>
      setTimeout(() => setProgressMsg(msg), (i + 1) * 4000)
    );
    return () => timers.forEach(clearTimeout);
  }, [analyzeState]);

  async function pickImage(useCamera: boolean) {
    if (useCamera) {
      const { status } = await ImagePicker.requestCameraPermissionsAsync();
      if (status !== "granted") {
        Alert.alert("カメラのアクセス許可が必要です", "設定からカメラへのアクセスを許可してください。");
        return;
      }
    } else {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== "granted") {
        Alert.alert("写真へのアクセス許可が必要です", "設定から写真へのアクセスを許可してください。");
        return;
      }
    }

    const result = useCamera
      ? await ImagePicker.launchCameraAsync({
          mediaTypes: ["images"],
          quality: 0.9,
          base64: true,
        })
      : await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ["images"],
          quality: 0.9,
          base64: true,
        });

    if (result.canceled) return;
    const asset = result.assets[0];

    if (asset.fileSize && asset.fileSize > MAX_FILE_BYTES) {
      Alert.alert(
        "画像が大きすぎます",
        `上限10MBです（現在約${Math.round(asset.fileSize / 1024 / 1024)}MB）。別の画像を選んでください。`
      );
      return;
    }

    track({ name: "image_source", properties: { source: useCamera ? "camera" : "library" } });

    // Vercel 上限(4.5MB)に収まるよう最長辺 1024px・品質 0.6 に圧縮（転送時間短縮）
    const compressed = await ImageManipulator.manipulateAsync(
      asset.uri,
      [{ resize: { width: 1024 } }],
      { compress: 0.6, format: ImageManipulator.SaveFormat.JPEG, base64: true }
    );

    setImageUri(compressed.uri);
    setImageBase64(compressed.base64 ?? null);
    setAnalyzeState("idle");
    setErrorMessage(null);
  }

  async function handleAnalyze() {
    if (!imageBase64) return;

    setAnalyzeState("loading");
    setErrorMessage(null);

    abortRef.current = new AbortController();
    const startedAt = Date.now();
    track({ name: "analyze_started" });

    try {
      const url = `${API_BASE_URL}/api/analyze`;
      if (__DEV__) console.log("[analyze] POST", url);

      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ imageBase64, mimeType: "image/jpeg" }),
        signal: abortRef.current.signal,
      });

      const rawText = await res.text();
      let data: Record<string, unknown> = {};
      try {
        data = JSON.parse(rawText);
      } catch {
        if (__DEV__) console.error("[analyze] non-JSON response", res.status, rawText);
        setAnalyzeState("error");
        track({ name: "analyze_error", properties: { type: "json", message: rawText.slice(0, 200), status: res.status } });
        setErrorMessage(
          __DEV__
            ? `[DEV] HTTP ${res.status} — レスポンスが JSON ではありません\n${rawText}\n\n→ ${url}`
            : getUserErrorMessage(res.status, "")
        );
        return;
      }

      if (!res.ok || !data.rules) {
        if (__DEV__) console.error("[analyze] error", res.status, data);
        track({ name: "analyze_error", properties: { type: "http", message: (data.error as string) ?? "", status: res.status } });
        setAnalyzeState("error");
        const userMessage = getUserErrorMessage(res.status, (data.error as string) ?? "");
        setErrorMessage(
          __DEV__
            ? `[DEV] HTTP ${res.status}\n${(data.error as string) ?? JSON.stringify(data, null, 2)}\n\n→ ${url}`
            : userMessage
        );
        return;
      }

      const rules: ParkingRules = migrateRules(data.rules);
      await AsyncStorage.setItem("parkingRules", JSON.stringify(rules));
      await AsyncStorage.setItem("uploadedImageUri", imageUri ?? "");

      // 履歴に追加（保存件数は設定から読む、デフォルト20件）
      const [historyRaw, limitRaw] = await Promise.all([
        AsyncStorage.getItem("analysisHistory"),
        AsyncStorage.getItem("historyLimit"),
      ]);
      let history: unknown[] = [];
      try { history = historyRaw ? JSON.parse(historyRaw) : []; } catch { history = []; }
      const limitNum = Number(limitRaw);
      const limit = !isNaN(limitNum) && limitNum > 0 ? limitNum : 20;
      history.unshift({ id: Date.now(), rules, imageUri, analyzedAt: new Date().toISOString() });
      await AsyncStorage.setItem("analysisHistory", JSON.stringify(history.slice(0, limit)));

      // プログレスバーを 100% まで埋めてから遷移
      progressAnim.stopAnimation();
      Animated.timing(progressAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: false,
      }).start(() => {
        track({ name: "analyze_success", properties: { duration_ms: Date.now() - startedAt } });
        router.push("/result");
      });
    } catch (err: unknown) {
      if (err instanceof Error && err.name === "AbortError") {
        setAnalyzeState("idle");
        setErrorMessage(null);
      } else {
        const msg = err instanceof Error ? err.message : String(err);
        if (__DEV__) console.error("[analyze] network error", msg);
        track({ name: "analyze_error", properties: { type: "network", message: msg } });
        setAnalyzeState("error");
        setErrorMessage(
          __DEV__
            ? `[DEV] ネットワークエラー\n${msg}\n\n→ ${API_BASE_URL}/api/analyze`
            : "通信に失敗しました。\n電波状況を確認してから再度お試しください。"
        );
      }
    }
  }

  function handleCancel() {
    abortRef.current?.abort();
  }

  function handleRetry() {
    setAnalyzeState("idle");
    setErrorMessage(null);
    handleAnalyze();
  }

  return (
    <View className="flex-1 bg-slate-50" style={{ paddingTop: insets.top }}>
      {/* ヘッダー */}
      <View className="flex-row items-center justify-between px-4 py-3">
        <Text className="text-xl font-bold text-slate-900">看板を読み取る</Text>
        <TouchableOpacity
          onPress={() => router.back()}
          className="h-9 w-9 items-center justify-center rounded-full bg-white"
          style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.08, shadowRadius: 3, elevation: 2 }}
          activeOpacity={0.7}
        >
          <Ionicons name="close" size={20} color="#475569" />
        </TouchableOpacity>
      </View>

      <ScrollView className="flex-1 px-4" contentContainerStyle={{ gap: 12, paddingBottom: 24 }}>
        {/* プレビュー */}
        <View
          className="h-52 w-full rounded-3xl overflow-hidden bg-white items-center justify-center"
          style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3 }}
        >
          {imageUri ? (
            <>
              <Image
                source={{ uri: imageUri }}
                className="absolute inset-0 w-full h-full"
                resizeMode="contain"
              />
              <TouchableOpacity
                onPress={() => { setImageUri(null); setImageBase64(null); setAnalyzeState("idle"); }}
                className="absolute top-3 right-3 rounded-full bg-black/50 px-3 py-1"
              >
                <Text className="text-xs text-white font-medium">選び直す</Text>
              </TouchableOpacity>
            </>
          ) : (
            <View className="items-center gap-2">
              <Ionicons name="image-outline" size={40} color="#CBD5E1" />
              <Text className="text-sm text-slate-400">ここに画像が表示されます</Text>
            </View>
          )}
        </View>

        {/* 入力ボタン */}
        <View
          className="rounded-2xl bg-white overflow-hidden"
          style={{ shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 }}
        >
          <TouchableOpacity
            onPress={() => pickImage(true)}
            activeOpacity={0.75}
            className="flex-row items-center gap-4 px-5 py-4"
          >
            <View className="h-10 w-10 rounded-full bg-blue-50 items-center justify-center">
              <Ionicons name="camera" size={20} color="#2563EB" />
            </View>
            <Text className="text-base font-medium text-slate-800">カメラで撮影する</Text>
          </TouchableOpacity>
          <View className="h-px bg-slate-100 mx-4" />
          <TouchableOpacity
            onPress={() => pickImage(false)}
            activeOpacity={0.75}
            className="flex-row items-center gap-4 px-5 py-4"
          >
            <View className="h-10 w-10 rounded-full bg-blue-50 items-center justify-center">
              <Ionicons name="images" size={20} color="#2563EB" />
            </View>
            <Text className="text-base font-medium text-slate-800">写真ライブラリから選ぶ</Text>
          </TouchableOpacity>
        </View>

        {/* エラー表示 */}
        {analyzeState === "error" && errorMessage && (
          <View className="rounded-2xl bg-red-50 border border-red-200 px-4 py-3">
            <Text className="text-sm text-red-800 font-mono" selectable>{errorMessage}</Text>
            <TouchableOpacity onPress={handleRetry} className="mt-2">
              <Text className="text-sm font-semibold text-red-700">再試行する →</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* 解析ボタン */}
        {analyzeState === "loading" ? (
          <View className="gap-3">
            <View
              className="w-full rounded-2xl bg-blue-600 px-5 py-5"
              style={{ shadowColor: "#2563EB", shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 5 }}
            >
              <Text className="text-base font-semibold text-white mb-3">{progressMsg}</Text>
              {/* プログレスバー */}
              <View className="h-2 w-full rounded-full bg-blue-400/40 overflow-hidden">
                <Animated.View
                  className="h-full rounded-full bg-white"
                  style={{
                    width: progressAnim.interpolate({
                      inputRange: [0, 1],
                      outputRange: ["0%", "100%"],
                    }),
                  }}
                />
              </View>
            </View>
            <TouchableOpacity
              onPress={handleCancel}
              className="w-full items-center justify-center rounded-2xl bg-white"
              style={{ minHeight: 48, shadowColor: "#000", shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 3, elevation: 1 }}
            >
              <Text className="text-base font-medium text-slate-600">キャンセル</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <TouchableOpacity
            onPress={handleAnalyze}
            disabled={!imageUri}
            activeOpacity={0.85}
            className={`h-14 w-full items-center justify-center rounded-2xl ${
              imageUri ? "bg-blue-600" : "bg-blue-200"
            }`}
            style={imageUri ? { shadowColor: "#2563EB", shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 5 } : {}}
          >
            <Text className={`text-base font-bold ${imageUri ? "text-white" : "text-blue-400"}`}>
              解析する
            </Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </View>
  );
}
