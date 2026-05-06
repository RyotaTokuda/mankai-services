import SwiftUI

/// iPhone: 記録詳細画面
/// 症状・強さ・時刻・薬・落ち着いた・メモ・環境データ・Healthデータを表示
struct RecordDetailView: View {
    let record: SymptomRecord

    @Environment(RecordStore.self) private var recordStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    @State private var showingSettlePicker = false

    var body: some View {
        NavigationStack {
            List {
                // ── 基本情報 ──
                Section {
                    LabeledContent(S.Common.symptom, value: record.displayName)
                    LabeledContent("強さ", value: "\(record.severity) - \(S.Severity.label(for: record.severity))")
                    LabeledContent(S.Common.recordedAt, value: record.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                    LabeledContent(S.Common.sourceDevice, value: record.sourceDevice == .watch ? S.Common.sourceWatch : S.Common.sourceiPhone)
                }

                // ── 服薬・落ち着いた ──
                Section {
                    if record.medicationTaken {
                        LabeledContent(S.Record.medicationTaken) {
                            if let at = record.medicationTakenAt {
                                Text(at.formatted(.dateTime.hour().minute()))
                            } else {
                                Image(systemName: "checkmark")
                            }
                        }
                        if let name = record.customMedicationName {
                            LabeledContent(S.Common.medication, value: name)
                        }
                    }

                    if let settled = record.settledAt {
                        LabeledContent(S.Record.settled, value: settled.formatted(.dateTime.hour().minute()))
                        let duration = settled.timeIntervalSince(record.createdAt)
                        if duration > 0 {
                            LabeledContent(S.Common.timeTaken, value: formatDuration(duration))
                        }
                        if let cause = record.settleCause {
                            LabeledContent(S.Common.settleCause, value: cause.label)
                        }
                    }
                }

                // ── 未解消の場合: 落ち着いたボタン ──
                if record.settledAt == nil {
                    Section {
                        Button {
                            showingSettlePicker = true
                        } label: {
                            Label(S.Record.settled, systemImage: "heart.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.green)
                    } footer: {
                        Text(S.Record.settledFooter).font(.caption)
                    }
                }

                // ── メモ ──
                if let note = record.note, !note.isEmpty {
                    Section(S.Common.note) {
                        Text(note)
                            .font(.body)
                    }
                }

                // ── 環境データ（Phase 2 で詳細化） ──
                if let env = record.environment {
                    Section(S.Environment.title) {
                        if let weather = env.weatherCondition {
                            LabeledContent(S.Environment.weather, value: weather)
                        }
                        if let pressure = env.pressure {
                            LabeledContent(S.Environment.pressure, value: String(format: "%.1f hPa", pressure))
                        }
                        if let temp = env.temperature {
                            LabeledContent(S.Environment.temperature, value: String(format: "%.1f℃", temp))
                        }
                        if let humidity = env.humidity {
                            LabeledContent(S.Environment.humidity, value: String(format: "%.0f%%", humidity))
                        }
                        if let aqi = env.airQualityIndex {
                            LabeledContent(S.Environment.airQuality, value: "\(aqi)")
                        }
                    }
                }

                // ── Health データ（Phase 2 で詳細化） ──
                if let health = record.healthSummary {
                    Section(S.Health.title) {
                        if let sleep = health.sleepDurationHours {
                            LabeledContent(S.Health.sleep, value: String(format: "%.1f時間", sleep))
                        }
                        if let hr = health.restingHeartRate {
                            LabeledContent(S.Health.heartRate, value: String(format: "%.0f bpm", hr))
                        }
                        if let steps = health.stepCount {
                            LabeledContent(S.Health.steps, value: "\(steps)歩")
                        }
                    }
                }

                // ── 操作 ──
                Section {
                    Button {
                        showingEdit = true
                    } label: {
                        Label(S.Record.edit, systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label(S.Record.delete, systemImage: "trash")
                    }
                }
            }
            .navigationTitle(record.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(S.Common.close) { dismiss() }
                }
            }
            .sheet(isPresented: $showingEdit) {
                RecordEditView(record: record)
            }
            .sheet(isPresented: $showingSettlePicker) {
                SettleTimePickerView(record: record) { date, cause in
                    recordStore.markSettled(id: record.id, at: date, cause: cause)
                    if let updated = recordStore.records.first(where: { $0.id == record.id }) {
                        WatchSyncService.shared.sendRecordUpdate(updated)
                    }
                    dismiss()
                }
            }
            .confirmationDialog(
                S.Record.deleteConfirm,
                isPresented: $showingDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(S.Record.delete, role: .destructive) {
                    recordStore.delete(id: record.id)
                    WatchSyncService.shared.sendRecordDeletion(id: record.id)
                    dismiss()
                }
            }
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes < 60 {
            return "\(minutes)分"
        }
        let hours = minutes / 60
        let remaining = minutes % 60
        return remaining > 0 ? "\(hours)時間\(remaining)分" : "\(hours)時間"
    }
}
