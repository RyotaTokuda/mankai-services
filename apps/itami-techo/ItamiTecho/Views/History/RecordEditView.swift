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
                Section(S.Common.symptom) {
                    LabeledContent(S.Common.symptom, value: record.displayName)
                }

                Section(S.Record.selectSeverity) {
                    Picker(S.Common.severity, selection: $severity) {
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
                        DatePicker(S.Common.medicationTime, selection: $medicationTakenAt,
                                   displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section(S.Record.addNote) {
                    TextField(S.Record.addNote, text: $note, axis: .vertical)
                        .lineLimit(1...6)
                }

                if record.settledAt == nil {
                    Section {
                        Button {
                            applyEdits(settleNow: true)
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
                    Button(S.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(S.Common.save) { applyEdits(settleNow: false) }
                }
            }
        }
    }

    private func applyEdits(settleNow: Bool) {
        var updated = record
        updated.severity = severity
        updated.note = note.isEmpty ? nil : note
        updated.medicationTaken = medicationTaken
        updated.medicationTakenAt = medicationTaken ? medicationTakenAt : nil
        if settleNow { updated.settledAt = Date() }
        recordStore.update(updated)
        WatchSyncService.shared.sendRecordUpdate(updated)
        dismiss()
    }
}
