import { View, Text, TouchableOpacity } from "react-native";

interface Props {
  feature: string;
  message: string;
  subMessage?: string;
  planRequired?: string;
  unlockWith?: string;
}

export function FeatureLockCard({ feature, message, subMessage, unlockWith, planRequired = "Plus" }: Props) {
  return (
    <View style={{ backgroundColor: "#F3F4F6", borderRadius: 16, padding: 16, alignItems: "center", gap: 8 }}>
      <Text style={{ fontSize: 14, fontWeight: "bold", color: "#374151" }}>🔒 {feature}</Text>
      <Text style={{ fontSize: 12, color: "#6B7280", textAlign: "center" }}>{message}</Text>
      {subMessage && (
        <Text style={{ fontSize: 11, color: "#9CA3AF", textAlign: "center" }}>{subMessage}</Text>
      )}
      <TouchableOpacity style={{ backgroundColor: "#3B82F6", borderRadius: 12, paddingHorizontal: 16, paddingVertical: 8, marginTop: 4 }}>
        <Text style={{ color: "#FFFFFF", fontSize: 13, fontWeight: "600" }}>{unlockWith ?? `${planRequired}プランにアップグレード`}</Text>
      </TouchableOpacity>
    </View>
  );
}
