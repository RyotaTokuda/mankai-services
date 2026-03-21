import { Modal, View, Text, TouchableOpacity } from "react-native";

interface Props {
  visible: boolean;
  onClose: () => void;
}

export function LimitReachedModal({ visible, onClose }: Props) {
  return (
    <Modal visible={visible} transparent animationType="fade">
      <View style={{ flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "center", alignItems: "center", padding: 24 }}>
        <View style={{ backgroundColor: "#FFFFFF", borderRadius: 20, padding: 24, width: "100%", maxWidth: 340, alignItems: "center", gap: 12 }}>
          <Text style={{ fontSize: 18, fontWeight: "bold", color: "#1F2937" }}>読み取り上限に達しました</Text>
          <Text style={{ fontSize: 14, color: "#6B7280", textAlign: "center", lineHeight: 20 }}>
            今月の無料読み取り回数を使い切りました。{"\n"}
            プランをアップグレードすると、引き続きご利用いただけます。
          </Text>
          <TouchableOpacity
            onPress={onClose}
            style={{ backgroundColor: "#3B82F6", borderRadius: 12, paddingHorizontal: 24, paddingVertical: 12, marginTop: 4 }}
          >
            <Text style={{ color: "#FFFFFF", fontSize: 15, fontWeight: "600" }}>閉じる</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}
