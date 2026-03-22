import SwiftUI

/// iPhone: 法的注意書き画面
struct LegalView: View {
    var body: some View {
        List {
            Section("重要な注意事項") {
                ForEach([
                    S.Legal.disclaimer1,
                    S.Legal.disclaimer2,
                    S.Legal.disclaimer3,
                    S.Legal.disclaimer4,
                ], id: \.self) { text in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text(text)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("データの取り扱い") {
                InfoRow(icon: "iphone", text: "すべてのデータは端末内に保存されます")
                InfoRow(icon: "arrow.up.right.circle", text: "健康データを外部に送信することはありません")
                InfoRow(icon: "location.slash", text: "位置情報は市区町村レベルに丸めて保存されます")
                InfoRow(icon: "chart.line.uptrend.xyaxis", text: "表示される傾向は記録データに基づく参考情報です")
            }
        }
        .navigationTitle(S.Legal.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
