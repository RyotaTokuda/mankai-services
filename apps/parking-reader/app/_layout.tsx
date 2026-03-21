import "../global.css";
import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { PostHogProvider } from "posthog-react-native";
import { AuthProvider, useAuth } from "../lib/AuthContext";
import { SubscriptionProvider } from "../lib/SubscriptionContext";

const POSTHOG_KEY = process.env.EXPO_PUBLIC_POSTHOG_KEY ?? "";

/**
 * AuthProvider の内側で useAuth() を使い、
 * user.id を SubscriptionProvider に渡す中間コンポーネント
 */
function AppProviders({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  return (
    <SubscriptionProvider userId={user?.id}>
      {children}
    </SubscriptionProvider>
  );
}

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
        <Stack.Screen
          name="compare"
          options={{ presentation: "modal", animation: "slide_from_bottom" }}
        />
        <Stack.Screen
          name="simulation"
          options={{ presentation: "modal", animation: "slide_from_bottom" }}
        />
        <Stack.Screen
          name="paywall"
          options={{ presentation: "modal", animation: "slide_from_bottom" }}
        />
      </Stack>
    </>
  );

  return (
    <SafeAreaProvider>
      <AuthProvider>
        <AppProviders>
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
        </AppProviders>
      </AuthProvider>
    </SafeAreaProvider>
  );
}
