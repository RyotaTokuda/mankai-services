import "../global.css";
import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { PostHogProvider } from "posthog-react-native";

const POSTHOG_KEY = process.env.EXPO_PUBLIC_POSTHOG_KEY ?? "";

export default function RootLayout() {
  const content = (
    <>
      <StatusBar style="dark" />
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen
          name="upload"
          options={{ presentation: "modal", animation: "slide_from_bottom" }}
        />
        <Stack.Screen name="result" />
      </Stack>
    </>
  );

  return (
    <SafeAreaProvider>
      {POSTHOG_KEY ? (
        // @ts-expect-error — PostHog の型定義が React 19 に未対応
        <PostHogProvider
          apiKey={POSTHOG_KEY}
          options={{ host: "https://us.i.posthog.com" }}
        >
          {content}
        </PostHogProvider>
      ) : (
        content
      )}
    </SafeAreaProvider>
  );
}
