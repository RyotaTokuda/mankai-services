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
    @State private var settlingRecord: SymptomRecord?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    latestUnsettledSection
                    symptomSection

                    if vm.hasSelection {
                        severitySection
                        optionSection

                        Button {
                            vm.performRecord(
                                recordStore: recordStore,
                                customSymptomStore: customSymptomStore,
                                environmentService: environmentService,
                                healthService: healthService,
                                planService: planService
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
            .sheet(isPresented: $vm.showingPaywall) { PaywallView() }
            .sheet(item: $settlingRecord) { record in
                SettleTimePickerView(record: record) { date, cause in
                    recordStore.markSettled(id: record.id, at: date, cause: cause)
                    if let updated = recordStore.records.first(where: { $0.id == record.id }) {
                        WatchSyncService.shared.sendRecordUpdate(updated)
                    }
                }
            }
        }
    }

    // MARK: - 直近の未解消記録セクション

    @ViewBuilder
    private var latestUnsettledSection: some View {
        if let unsettled = recordStore.records.first(where: { $0.settledAt == nil }) {
            VStack(alignment: .leading, spacing: 6) {
                Text(S.Record.latestUnsettledLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(unsettled.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(unsettled.createdAt.formatted(.dateTime.hour().minute()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        settlingRecord = unsettled
                    } label: {
                        Label(S.Record.settled, systemImage: "heart.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
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
                if canAddCustom {
                    vm.showingAddCustom = true
                } else {
                    vm.showingPaywall = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: canAddCustom ? "plus.circle.fill" : "lock.fill")
                        .font(.title3)
                        .foregroundStyle(canAddCustom ? Color.accentColor : Color.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(S.Common.addSymptom)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(canAddCustom ? Color.accentColor : Color.secondary)
                        if !planService.isPremium {
                            Text("\(customSymptomStore.symptoms.count)/\(planService.maxCustomSymptoms)")
                                .font(.caption2)
                                .foregroundStyle(canAddCustom ? Color.secondary : Color.red)
                                .monospacedDigit()
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 3])
                        )
                        .foregroundStyle(canAddCustom ? Color.accentColor.opacity(0.5) : Color(.systemGray4))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
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
                    S.Common.dateTime,
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
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
