import SwiftUI

/// iPhone: 記録完了シート
/// 完了メッセージ + 見返り + 服薬・落ち着いた クイックアクション
struct RecordCompleteView: View {
    let record: SymptomRecord

    @Environment(RecordStore.self) private var recordStore
    @Environment(\.dismiss) private var dismiss

    @State private var medicationTapped = false
    @State private var settledTapped = false
    @State private var selectedCause: SettleCause? = nil

    private var todayCount: Int { recordStore.todayRecords.count }
    private var isMedTaken: Bool { medicationTapped || record.medicationTaken }
    private var isSettled: Bool { settledTapped || record.settledAt != nil }

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

            // ── 解消要因ピッカー（落ち着いた後に表示） ──
            if isSettled {
                VStack(spacing: 8) {
                    Text(S.Record.whySettled)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(SettleCause.allCases) { cause in
                            Button {
                                selectedCause = cause
                                recordStore.markSettled(id: record.id, cause: cause)
                            } label: {
                                VStack(spacing: 3) {
                                    Image(systemName: cause.icon)
                                        .font(.caption)
                                    Text(cause.label)
                                        .font(.caption2)
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(selectedCause == cause ? Color.green.opacity(0.15) : Color(.systemGray6))
                                .foregroundStyle(selectedCause == cause ? .green : .secondary)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedCause == cause ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.2), value: isSettled)
            }

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
        .presentationDetents([.medium, .large])
        .animation(.easeInOut(duration: 0.2), value: isSettled)
        .onAppear {
            // 既存レコードに解消済みがある場合は要因を復元
            selectedCause = record.settleCause
        }
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
