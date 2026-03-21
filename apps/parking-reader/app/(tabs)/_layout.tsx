import { Tabs } from "expo-router";
import { Ionicons } from "@expo/vector-icons";

type IconName = React.ComponentProps<typeof Ionicons>["name"];

function TabIcon({ name, color }: { name: IconName; color: string }) {
  return <Ionicons name={name} size={24} color={color} />;
}

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: "#2563EB",
        tabBarInactiveTintColor: "#94A3B8",
        tabBarStyle: {
          backgroundColor: "#FFFFFF",
          borderTopColor: "#E2E8F0",
          borderTopWidth: 1,
          height: 84,
          paddingBottom: 28,
          paddingTop: 8,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: "600",
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "ホーム",
          tabBarIcon: ({ color, focused }) => (
            <TabIcon name={focused ? "home" : "home-outline"} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="saved"
        options={{
          title: "保存済み",
          tabBarIcon: ({ color, focused }) => (
            <TabIcon name={focused ? "bookmark" : "bookmark-outline"} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="history"
        options={{
          title: "履歴",
          tabBarIcon: ({ color, focused }) => (
            <TabIcon name={focused ? "time" : "time-outline"} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: "設定",
          tabBarIcon: ({ color, focused }) => (
            <TabIcon name={focused ? "settings" : "settings-outline"} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
