import SwiftUI

/// Watch: 症状選択画面（1タップ目）
/// よく使う症状を上に、不調時でも迷わない大きなボタン
struct WatchSymptomSelectView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(CustomSymptomStore.self) private var customSymptomStore

    /// デフォルト症状をよく使う順に並び替え
    private var sortedDefaultSymptoms: [SymptomType] {
        let counts = Dictionary(
            grouping: recordStore.records.compactMap(\.symptomType),
            by: { $0 }
        ).mapValues(\.count)
        return SymptomType.allCases.sorted { (counts[$0] ?? 0) > (counts[$1] ?? 0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(sortedDefaultSymptoms, id: \.self) { symptom in
                    NavigationLink {
                        WatchSeveritySelectView(
                            symptomType: symptom,
                            customSymptomId: nil,
                            customSymptomName: nil
                        )
                    } label: {
                        Text(S.Symptom.name(for: symptom))
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }

                // カスタム症状
                ForEach(customSymptomStore.sortedByUseCount) { custom in
                    NavigationLink {
                        WatchSeveritySelectView(
                            symptomType: nil,
                            customSymptomId: custom.id,
                            customSymptomName: custom.name
                        )
                    } label: {
                        HStack {
                            if let emoji = custom.emoji {
                                Text(emoji)
                            }
                            Text(custom.name)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(S.Record.selectSymptom)
        .navigationBarTitleDisplayMode(.inline)
    }
}
