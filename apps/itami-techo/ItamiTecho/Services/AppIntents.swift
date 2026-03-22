import AppIntents

/// Siri ショートカット: 症状を記録
struct RecordSymptomIntent: AppIntent {
    static var title: LocalizedStringResource = "不調を記録"
    static var description: IntentDescription = "痛み手帳に症状を記録します"

    @Parameter(title: "症状")
    var symptomName: String

    @Parameter(title: "強さ (1-5)", default: 3)
    var severity: Int

    static var parameterSummary: some ParameterSummary {
        Summary("「\(\.$symptomName)」を強さ \(\.$severity) で記録")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // SymptomType に変換を試みる
        let symptomType = SymptomType.allCases.first { type in
            S.Symptom.name(for: type) == symptomName
        }

        let clampedSeverity = min(max(severity, 1), 5)

        let record = SymptomRecord(
            symptomType: symptomType,
            customSymptomId: nil,
            customSymptomName: symptomType == nil ? symptomName : nil,
            severity: clampedSeverity,
            sourceDevice: .iPhone
        )

        let store = RecordStore()
        store.add(record)

        let name = symptomType.map { S.Symptom.name(for: $0) } ?? symptomName
        return .result(dialog: "\(name)（\(S.Severity.label(for: clampedSeverity))）を記録しました")
    }
}

/// Siri ショートカット: 今日の記録を確認
struct TodaySummaryIntent: AppIntent {
    static var title: LocalizedStringResource = "今日の記録を確認"
    static var description: IntentDescription = "痛み手帳の今日の記録を確認します"

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = RecordStore()
        let count = store.todayRecords.count

        if count == 0 {
            return .result(dialog: "今日の記録はまだありません")
        }

        let symptoms = store.todayRecords.map { record in
            record.symptomType.map { S.Symptom.name(for: $0) } ?? record.customSymptomName ?? "カスタム"
        }
        let summary = symptoms.joined(separator: "、")
        return .result(dialog: "今日は\(count)件の記録があります: \(summary)")
    }
}

/// App Shortcuts の登録
struct ItamiTechoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RecordSymptomIntent(),
            phrases: [
                "\(.applicationName) に記録して",
                "\(.applicationName) で不調を記録して",
            ],
            shortTitle: "不調を記録",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: TodaySummaryIntent(),
            phrases: [
                "\(.applicationName) の今日の記録を見せて",
                "\(.applicationName) で今日の記録を確認して",
            ],
            shortTitle: "今日の記録",
            systemImageName: "list.bullet"
        )
    }
}
