import SwiftUI

/// iPhone: 記録編集画面
struct RecordEditView: View {
    let record: SymptomRecord

    @Environment(RecordStore.self) private var recordStore
    @Environment(\.dismiss) private var dismiss

    @State private var severity: Int
    @State private var note: String
    @State private var medicationTaken: Bool
    @State private var medicationTakenAt: Date

    init(record: SymptomRecord) {
        self.record = record
        _severity = State(initialValue: record.severity)
        _note = State(initialValue: record.note ?? "")
        _medicationTaken = State(initialValue: record.medicationTaken)
        _medicationTakenAt = State(initialValue: record.medicationTakenAt ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("症状") {
                    LabeledContent("症状", value: record.displayName)
                }

                Section(S.Record.selectSeverity) {
                    Picker("強さ", selection: $severity) {
                        ForEach(1...5, id: \.self) { level in
                            Text("\(level) - \(S.Severity.label(for: level))").tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section {
                    Toggle(S.Record.medication, isOn: $medicationTaken)
                    if medicationTaken {
                        DatePicker("服薬時刻", selection: $medicationTakenAt, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section(S.Record.addNote) {
                    TextField(S.Record.addNote, text: $note, axis: .vertical)
                        .lineLimit(1...6)
                }

                // 落ち着いた時刻の設定
                if record.settledAt == nil {
                    Section {
                        Button {
                            var updated = record
                            updated.severity = severity
                            updated.note = note.isEmpty ? nil : note
                            updated.medicationTaken = medicationTaken
                            updated.medicationTakenAt = medicationTaken ? medicationTakenAt : nil
                            updated.settledAt = Date()
                            recordStore.update(updated)
                            WatchSyncService.shared.sendRecordUpdate(updated)
                            dismiss()
                        } label: {
                            Label(S.Record.settled, systemImage: "heart.fill")
                        }
                    }
                }
            }
            .navigationTitle(S.Record.edit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                }
            }
        }
    }

    private func save() {
        var updated = record
        updated.severity = severity
        updated.note = note.isEmpty ? nil : note
        updated.medicationTaken = medicationTaken
        updated.medicationTakenAt = medicationTaken ? medicationTakenAt : nil
        recordStore.update(updated)
        WatchSyncService.shared.sendRecordUpdate(updated)
        dismiss()
    }
}
