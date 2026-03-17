import { View } from "react-native";

// SVGが使えない環境向けにシンプルなテキストアイコン代替
// 本番では react-native-svg + lucide-react-native に差し替える

type IconProps = { color: string; size?: number };

export function Home({ color }: IconProps) {
  return (
    <View style={{ width: 24, height: 24, alignItems: "center", justifyContent: "center" }}>
      <View style={{ width: 20, height: 18, borderWidth: 2, borderColor: color, borderRadius: 3, position: "relative" }}>
        <View style={{ position: "absolute", top: -8, left: 3, width: 0, height: 0, borderLeftWidth: 7, borderRightWidth: 7, borderBottomWidth: 9, borderStyle: "solid", borderLeftColor: "transparent", borderRightColor: "transparent", borderBottomColor: color }} />
      </View>
    </View>
  );
}

export function History({ color }: IconProps) {
  return (
    <View style={{ width: 24, height: 24, alignItems: "center", justifyContent: "center" }}>
      <View style={{ width: 20, height: 20, borderRadius: 10, borderWidth: 2, borderColor: color }} />
    </View>
  );
}

export function Settings({ color }: IconProps) {
  return (
    <View style={{ width: 24, height: 24, alignItems: "center", justifyContent: "center" }}>
      <View style={{ width: 8, height: 8, borderRadius: 4, borderWidth: 2, borderColor: color }} />
    </View>
  );
}
