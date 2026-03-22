import SwiftUI
import WatchKit

/// Watch: 強さ選択画面（2タップ目）
/// タップ即記録完了 → 記録完了画面に遷移
struct WatchSeveritySelectView: View {
    let symptomType: SymptomType?
    let customSymptomId: UUID?
    let customSymptomName: String?

    @Environment(RecordStore.self) private var recordStore
    @Environment(CustomSymptomStore.self) private var customSymptomStore
    @State private var completedRecord: SymptomRecord?

    var body: some View {
        if let record = completedRecord {
            WatchRecordCompleteView(record: record)
        } else {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { level in
                        Button {
                            record(severity: level)
                        } label: {
                            HStack {
                                Text("\(level)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .frame(width: 28)
                                Text(S.Severity.label(for: level))
                                    .font(.body)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SymptomRecord.color(for: level))
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle(S.Record.selectSeverity)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func record(severity: Int) {
        let record = SymptomRecord(
            symptomType: symptomType,
            customSymptomId: customSymptomId,
            customSymptomName: customSymptomName,
            severity: severity,
            sourceDevice: .watch
        )
        recordStore.add(record)

        // カスタム症状の使用回数を更新
        if let customId = customSymptomId {
            customSymptomStore.incrementUseCount(id: customId)
        }

        // WatchConnectivity で iPhone に送信
        WatchSyncService.shared.sendRecord(record)

        // ハプティクスで成功フィードバック
        WKInterfaceDevice.current().play(.success)

        completedRecord = record
    }
}
