import SwiftUI

/// iPhone: 記録完了シート
/// 完了メッセージ + 見返り + 服薬・落ち着いた クイックアクション
struct RecordCompleteView: View {
    let record: SymptomRecord

    @Environment(RecordStore.self) private var recordStore
    @Environment(\.dismiss) private var dismiss

    @State private var medicationTapped = false
    @State private var settledTapped = false

    private var todayCount: Int {
        recordStore.todayRecords.count
    }

    private var isMedTaken: Bool {
        medicationTapped || record.medicationTaken
    }

    private var isSettled: Bool {
        settledTapped || record.settledAt != nil
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text(S.Record.done)
                .font(.title2)
                .fontWeight(.bold)

            Text(S.Feedback.todayCount(todayCount))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // ── クイックアクション ──
            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "pills.fill",
                    label: S.Record.medicationTaken,
                    isActive: isMedTaken,
                    color: .orange
                ) {
                    guard !isMedTaken else { return }
                    medicationTapped = true
                    recordStore.markMedicationTaken(id: record.id)
                }

                QuickActionButton(
                    icon: "heart.fill",
                    label: S.Record.settled,
                    isActive: isSettled,
                    color: .green
                ) {
                    guard !isSettled else { return }
                    settledTapped = true
                    recordStore.markSettled(id: record.id)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text(S.Common.close)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .presentationDetents([.medium])
    }
}

private struct QuickActionButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isActive ? color : .secondary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(isActive ? color : .secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(isActive ? color.opacity(0.12) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? color.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(isActive)
    }
}
