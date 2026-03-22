import SwiftUI

/// Watch: 簡易履歴画面（直近の記録を数件確認）
struct WatchHistoryView: View {
    @Environment(RecordStore.self) private var recordStore

    /// 直近10件を表示
    private var recentRecords: [SymptomRecord] {
        Array(recordStore.records.prefix(10))
    }

    var body: some View {
        if recentRecords.isEmpty {
            Text(S.History.noRecords)
                .font(.caption)
                .foregroundStyle(.secondary)
                .navigationTitle(S.History.title)
        } else {
            List(recentRecords) { record in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(symptomName(for: record))
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(severityDots(record.severity))
                            .font(.caption2)
                    }

                    HStack(spacing: 6) {
                        Text(record.createdAt.formatted(.dateTime.month().day().hour().minute()))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if record.medicationTaken {
                            Image(systemName: "pills.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        if record.settledAt != nil {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .navigationTitle(S.History.title)
        }
    }

    private func symptomName(for record: SymptomRecord) -> String {
        record.symptomType.map { S.Symptom.name(for: $0) }
            ?? record.customSymptomName
            ?? S.Symptom.custom
    }

    /// 強さを●の数で表現（Watch では文字より視覚的に分かりやすい）
    private func severityDots(_ severity: Int) -> String {
        String(repeating: "●", count: severity)
            + String(repeating: "○", count: 5 - severity)
    }
}
