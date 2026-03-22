import SwiftUI

/// iPhone: メイン記録画面
/// 症状選択 → 強さ → オプション（薬・メモ） → 記録
struct RecordView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(CustomSymptomStore.self) private var customSymptomStore
    @Environment(PlanService.self) private var planService
    @Environment(EnvironmentService.self) private var environmentService
    @Environment(HealthService.self) private var healthService

    @State private var vm = RecordViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    symptomSection

                    if vm.hasSelection {
                        severitySection
                        optionSection

                        Button {
                            vm.performRecord(
                                recordStore: recordStore,
                                customSymptomStore: customSymptomStore,
                                environmentService: environmentService,
                                healthService: healthService
                            )
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
            .sheet(isPresented: $vm.showingAddCustom) {
                AddCustomSymptomView()
            }
            .sheet(isPresented: $vm.showingComplete) {
                if let record = vm.lastRecordedRecord {
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

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 10) {
                ForEach(vm.sortedDefaultSymptoms(from: recordStore.records), id: \.self) { symptom in
                    SymptomButton(
                        label: S.Symptom.name(for: symptom),
                        isSelected: vm.selectedSymptomType == symptom
                    ) {
                        vm.selectedSymptomType = symptom
                        vm.selectedCustomSymptom = nil
                    }
                }
            }
            .padding(.horizontal)

            if !customSymptomStore.symptoms.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 10) {
                    ForEach(customSymptomStore.sortedByUseCount) { custom in
                        SymptomButton(
                            label: (custom.emoji ?? "") + custom.name,
                            isSelected: vm.selectedCustomSymptom?.id == custom.id
                        ) {
                            vm.selectedCustomSymptom = custom
                            vm.selectedSymptomType = nil
                        }
                    }
                }
                .padding(.horizontal)
            }

            let canAddCustom = customSymptomStore.symptoms.count < planService.maxCustomSymptoms
            Button {
                vm.showingAddCustom = true
            } label: {
                Label(S.Common.addSymptom, systemImage: "plus")
                    .font(.caption)
            }
            .disabled(!canAddCustom)
            .padding(.horizontal)

            if !canAddCustom && !planService.isPremium {
                Text(S.Common.customSymptomLimitPremium)
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
                        vm.severity = level
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
                        .background(vm.severity == level ? SymptomRecord.color(for: level).opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                    .foregroundStyle(vm.severity == level ? SymptomRecord.color(for: level) : .secondary)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - オプションセクション

    private var optionSection: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $vm.medicationTaken) {
                Label(S.Record.medication, systemImage: "pills.fill")
            }
            .padding(.horizontal)

            Toggle(isOn: $vm.isPastDate) {
                Label(S.Common.pastRecord, systemImage: "clock.arrow.circlepath")
            }
            .padding(.horizontal)

            if vm.isPastDate {
                DatePicker(
                    "日時",
                    selection: $vm.recordDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding(.horizontal)
            }

            TextField(S.Record.addNote, text: $vm.note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .padding(.horizontal)
        }
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
