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
  | { name: "settings_opened" };

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
