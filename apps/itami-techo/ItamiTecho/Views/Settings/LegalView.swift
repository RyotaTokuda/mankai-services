import SwiftUI

/// iPhone: 法的注意書き画面
struct LegalView: View {
    var body: some View {
        List {
            Section(S.Legal.importantNotice) {
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

            Section(S.Legal.dataHandlingTitle) {
                InfoRow(icon: "iphone", text: S.Legal.dataLocal)
                InfoRow(icon: "arrow.up.right.circle", text: S.Legal.dataNoExternal)
                InfoRow(icon: "location.slash", text: S.Legal.locationRounded)
                InfoRow(icon: "chart.line.uptrend.xyaxis", text: S.Legal.trendsDisclaimer)
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
