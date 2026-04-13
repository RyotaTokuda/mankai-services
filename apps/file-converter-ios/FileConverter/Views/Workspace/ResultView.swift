import SwiftUI

struct ResultView: View {
    let results: [ConversionResult]
    let onClear: () -> Void

    @State private var isExporting = false
    @State private var exportURLs: [URL] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("変換結果", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)

                Spacer()

                Button("クリア", role: .destructive) {
                    onClear()
                }
                .font(.caption)
            }

            ForEach(results) { result in
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.outputFileName)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(formatFileSize(result.outputFileSize))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    ShareLink(item: result.outputURL) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Save All button
            if results.count > 1 {
                Button {
                    exportURLs = results.map(\.outputURL)
                    isExporting = true
                } label: {
                    Label("すべて保存", systemImage: "square.and.arrow.down.on.square")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal)
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
