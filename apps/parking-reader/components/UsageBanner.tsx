import { View, Text } from "react-native";
import { usePlan } from "../lib/SubscriptionContext";

export function UsageBanner() {
  const { state, remainingReads } = usePlan();

  if (state.planType !== "free") return null;

  return (
    <View style={{ backgroundColor: "#FEF3C7", borderRadius: 12, padding: 12, marginBottom: 12 }}>
      <Text style={{ fontSize: 13, color: "#92400E" }}>
        今月の残り読み取り回数: {remainingReads}回
      </Text>
    </View>
  );
}
