import { usePostHog } from "posthog-react-native";

// イベント定義（追加はここだけ）
export type AnalyticsEvent =
  | { name: "analyze_started" }
  | { name: "analyze_success"; properties: { duration_ms: number } }
  | { name: "analyze_error"; properties: { type: "network" | "http" | "json"; message: string; status?: number } }
  | { name: "image_source"; properties: { source: "camera" | "library" } }
  | { name: "result_viewed" }
  | { name: "result_closed" }
  | { name: "history_item_opened" }
  | { name: "settings_opened" }
  // 課金関連
  | { name: "paywall_viewed"; properties: { source: string } }
  | { name: "paywall_plan_selected"; properties: { plan: "pass_24h" | "premium" } }
  | { name: "purchase_started"; properties: { plan: "pass_24h" | "premium" } }
  | { name: "purchase_success"; properties: { plan: "pass_24h" | "premium" } }
  | { name: "purchase_failed"; properties: { plan: "pass_24h" | "premium"; error?: string } }
  | { name: "purchase_restore_attempted" }
  | { name: "purchase_restore_success" }
  | { name: "limit_warning_shown"; properties: { remaining: number } }
  | { name: "limit_reached_modal_shown" }
  // 保存・比較
  | { name: "parking_saved"; properties: { count: number } }
  | { name: "parking_save_limit_hit"; properties: { limit: number } }
  | { name: "compare_started"; properties: { count: number } }
  | { name: "simulation_viewed" };

export function useAnalytics() {
  const posthog = usePostHog();

  function track(event: AnalyticsEvent) {
    if (!posthog) return;
    if ("properties" in event) {
      posthog.capture(event.name, event.properties);
    } else {
      posthog.capture(event.name);
    }
  }

  return { track };
}
