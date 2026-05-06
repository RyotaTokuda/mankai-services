import SwiftUI
import WatchKit

/// Watch: 直近記録への薬・落ち着いたクイックアクション
struct WatchQuickActionButton: View {
    let record: SymptomRecord
    let action: QuickAction

    @Environment(RecordStore.self) private var recordStore
    @State private var isDone = false
    @State private var showingSettlePicker = false

    enum QuickAction {
        case medication
        case settled

        var label: String {
            switch self {
            case .medication: S.Watch.tookMedicine
            case .settled:    S.Watch.settledDown
            }
        }

        var icon: String {
            switch self {
            case .medication: "pills.fill"
            case .settled:    "heart.fill"
            }
        }

        var tint: Color {
            switch self {
            case .medication: .orange
            case .settled:    .green
            }
        }
    }

    var body: some View {
        if isDone {
            Label(action.label, systemImage: "checkmark")
                .font(.caption2)
                .foregroundStyle(.secondary)
        } else {
            Button {
                if action == .settled {
                    showingSettlePicker = true
                } else {
                    performAction(at: Date())
                }
            } label: {
                Label(action.label, systemImage: action.icon)
                    .font(.caption2)
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.bordered)
            .tint(action.tint)
            .sheet(isPresented: $showingSettlePicker) {
                WatchSettleTimePickerView(record: record) { date in
                    performAction(at: date)
                }
            }
        }
    }

    private func performAction(at date: Date) {
        switch action {
        case .medication:
            recordStore.markMedicationTaken(id: record.id)
        case .settled:
            recordStore.markSettled(id: record.id, at: date)
        }

        if let updated = recordStore.records.first(where: { $0.id == record.id }) {
            WatchSyncService.shared.sendRecordUpdate(updated)
        }

        WKInterfaceDevice.current().play(.click)
        isDone = true
    }
}
