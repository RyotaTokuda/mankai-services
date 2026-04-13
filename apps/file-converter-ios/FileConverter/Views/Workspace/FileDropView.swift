import SwiftUI
import UniformTypeIdentifiers

struct FileDropView: View {
    let files: [InputFile]
    let acceptedTypes: [UTType]
    let onAdd: ([URL]) -> Void
    let onRemove: (InputFile) -> Void
    let onShowPicker: () -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 12) {
            if files.isEmpty {
                // Empty state — drop zone
                dropZone
            } else {
                // File list
                fileList

                // Add more button
                Button {
                    onShowPicker()
                } label: {
                    Label("ファイルを追加", systemImage: "plus")
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Drop Zone

    private var dropZone: some View {
        Button {
            onShowPicker()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)

                Text("ファイルを選択")
                    .font(.headline)

                Text("タップして選択、またはドラッグ&ドロップ")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8])
                    )
                    .foregroundStyle(isTargeted ? Color.accentColor : Color.appSeparator)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isTargeted ? Color.accentColor.opacity(0.05) : Color.secondaryBackground)
            )
        }
        .buttonStyle(.plain)
        .dropDestination(for: URL.self) { urls, _ in
            onAdd(urls)
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }

    // MARK: - File List

    private var fileList: some View {
        VStack(spacing: 6) {
            ForEach(files) { file in
                HStack {
                    Image(systemName: iconForFile(file))
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.fileName)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(formatFileSize(file.fileSize))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    Button {
                        onRemove(file)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Helpers

    private func iconForFile(_ file: InputFile) -> String {
        let ext = file.fileExtension
        switch ext {
        case "pdf": return "doc.richtext"
        case "mp4", "mov", "avi", "mkv": return "film"
        default: return "photo"
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
