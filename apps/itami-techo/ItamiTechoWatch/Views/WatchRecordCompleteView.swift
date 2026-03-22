import SwiftUI

/// Watch: 記録完了画面
/// 完了メッセージ + 追加アクション（薬・落ち着いた）+ 見返りメッセージ
struct WatchRecordCompleteView: View {
    let record: SymptomRecord

    @Environment(RecordStore.self) private var recordStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingMedicationDone = false
    @State private var showingSettledDone = false

    /// 今日の記録件数
    private var todayCount: Int {
        recordStore.todayRecords.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // ── 完了メッセージ ──
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)

                Text(S.Record.done)
                    .font(.headline)

                // ── 見返りメッセージ ──
                Text(S.Feedback.todayCount(todayCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                // ── 追加アクション ──
                if !showingMedicationDone {
                    Button {
                        recordStore.markMedicationTaken(id: record.id)
                        WatchSyncService.shared.sendRecordUpdate(
                            recordStore.records.first { $0.id == record.id } ?? record
                        )
                        showingMedicationDone = true
                    } label: {
                        Label(S.Watch.tookMedicine, systemImage: "pills.fill")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                } else {
                    Label(S.Watch.tookMedicine, systemImage: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !showingSettledDone {
                    Button {
                        recordStore.markSettled(id: record.id)
                        WatchSyncService.shared.sendRecordUpdate(
                            recordStore.records.first { $0.id == record.id } ?? record
                        )
                        showingSettledDone = true
                    } label: {
                        Label(S.Watch.settledDown, systemImage: "heart.fill")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                } else {
                    Label(S.Watch.settledDown, systemImage: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // ── 閉じる ──
                Button {
                    dismiss()
                } label: {
                    Text("閉じる")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 4)
        }
        .navigationBarBackButtonHidden(true)
    }
}
