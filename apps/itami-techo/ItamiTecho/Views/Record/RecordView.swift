import SwiftUI

/// iPhone: メイン記録画面
/// 症状選択 → 強さ → オプション（薬・メモ） → 記録
struct RecordView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(CustomSymptomStore.self) private var customSymptomStore
    @Environment(PlanService.self) private var planService
    @Environment(EnvironmentService.self) private var environmentService
    @Environment(HealthService.self) private var healthService

    @State private var selectedSymptomType: SymptomType?
    @State private var selectedCustomSymptom: CustomSymptom?
    @State private var severity: Int = 3
    @State private var medicationTaken = false
    @State private var note = ""
    @State private var recordDate = Date()
    @State private var isPastDate = false
    @State private var showingAddCustom = false
    @State private var showingComplete = false
    @State private var lastRecordedRecord: SymptomRecord?

    private var hasSelection: Bool {
        selectedSymptomType != nil || selectedCustomSymptom != nil
    }

    /// デフォルト症状をよく使う順に並び替え
    private var sortedDefaultSymptoms: [SymptomType] {
        let counts = Dictionary(
            grouping: recordStore.records.compactMap(\.symptomType),
            by: { $0 }
        ).mapValues(\.count)
        return SymptomType.allCases.sorted { (counts[$0] ?? 0) > (counts[$1] ?? 0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ── 症状選択 ──
                    symptomSection

                    if hasSelection {
                        // ── 強さ選択 ──
                        severitySection

                        // ── オプション ──
                        optionSection

                        // ── 記録ボタン ──
                        Button {
                            performRecord()
                        } label: {
                            Text(S.Record.title)
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(S.Record.title)
            .sheet(isPresented: $showingAddCustom) {
                AddCustomSymptomView()
            }
            .sheet(isPresented: $showingComplete) {
                if let record = lastRecordedRecord {
                    RecordCompleteView(record: record)
                }
            }
        }
    }

    // MARK: - 症状選択セクション

    private var symptomSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.Record.selectSymptom)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            // デフォルト症状
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 10) {
                ForEach(sortedDefaultSymptoms, id: \.self) { symptom in
                    SymptomButton(
                        label: S.Symptom.name(for: symptom),
                        isSelected: selectedSymptomType == symptom
                    ) {
                        selectedSymptomType = symptom
                        selectedCustomSymptom = nil
                    }
                }
            }
            .padding(.horizontal)

            // カスタム症状
            if !customSymptomStore.symptoms.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 10) {
                    ForEach(customSymptomStore.sortedByUseCount) { custom in
                        SymptomButton(
                            label: (custom.emoji ?? "") + custom.name,
                            isSelected: selectedCustomSymptom?.id == custom.id
                        ) {
                            selectedCustomSymptom = custom
                            selectedSymptomType = nil
                        }
                    }
                }
                .padding(.horizontal)
            }

            // カスタム追加ボタン
            let canAddCustom = customSymptomStore.symptoms.count < planService.maxCustomSymptoms
            Button {
                showingAddCustom = true
            } label: {
                Label("症状を追加", systemImage: "plus")
                    .font(.caption)
            }
            .disabled(!canAddCustom)
            .padding(.horizontal)

            if !canAddCustom && !planService.isPremium {
                Text("カスタム症状の追加はプレミアムで無制限に")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - 強さ選択セクション

    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.Record.selectSeverity)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        severity = level
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(level)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(S.Severity.label(for: level))
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(severity == level ? SymptomRecord.color(for: level).opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                    .foregroundStyle(severity == level ? SymptomRecord.color(for: level) : .secondary)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - オプションセクション

    private var optionSection: some View {
        VStack(spacing: 12) {
            // 薬を飲んだ
            Toggle(isOn: $medicationTaken) {
                Label(S.Record.medication, systemImage: "pills.fill")
            }
            .padding(.horizontal)

            // 過去日の記録
            Toggle(isOn: $isPastDate) {
                Label("過去の記録", systemImage: "clock.arrow.circlepath")
            }
            .padding(.horizontal)

            if isPastDate {
                DatePicker(
                    "日時",
                    selection: $recordDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding(.horizontal)
            }

            // メモ
            TextField(S.Record.addNote, text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .padding(.horizontal)
        }
    }

    // MARK: - 記録実行

    private func performRecord() {
        let record = SymptomRecord(
            symptomType: selectedSymptomType,
            customSymptomId: selectedCustomSymptom?.id,
            customSymptomName: selectedCustomSymptom?.name,
            severity: severity,
            sourceDevice: .iPhone,
            note: note.isEmpty ? nil : note,
            medicationTaken: medicationTaken,
            date: isPastDate ? recordDate : Date()
        )

        recordStore.add(record)

        if let customId = selectedCustomSymptom?.id {
            customSymptomStore.incrementUseCount(id: customId)
        }

        WatchSyncService.shared.sendRecord(record)

        // 環境データ + Health データを非同期で取得して後付け（過去日は除く）
        if !isPastDate {
            let recordId = record.id
            Task {
                async let envSnapshot = environmentService.createSnapshot()
                async let healthSnapshot = healthService.createSnapshot()

                let env = await envSnapshot
                recordStore.attachEnvironment(id: recordId, snapshot: env)

                let health = await healthSnapshot
                if health.sleepDurationHours != nil || health.avgHeartRate != nil || health.stepCount != nil {
                    recordStore.attachHealth(id: recordId, snapshot: health)
                }

                // 同期を更新
                if let updated = recordStore.records.first(where: { $0.id == recordId }) {
                    WatchSyncService.shared.sendRecordUpdate(updated)
                }
            }
        }

        lastRecordedRecord = record
        showingComplete = true

        // リセット
        selectedSymptomType = nil
        selectedCustomSymptom = nil
        severity = 3
        medicationTaken = false
        note = ""
        isPastDate = false
        recordDate = Date()
    }

}

// MARK: - 症状ボタン

private struct SymptomButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
