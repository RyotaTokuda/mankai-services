import SwiftUI
import WatchKit

/// Watch: 落ち着いた時刻入力
/// デジタルクラウンで5分刻み調整、確認ボタンで記録
struct WatchSettleTimePickerView: View {
    let record: SymptomRecord
    let onConfirm: (Date) -> Void

    @Environment(\.dismiss) private var dismiss

    // 5分刻みの選択肢インデックス（0〜287 = 24h × 12steps）
    @State private var selectedStep: Int

    private static let totalSteps = 24 * 12  // 288

    init(record: SymptomRecord, onConfirm: @escaping (Date) -> Void) {
        self.record = record
        self.onConfirm = onConfirm
        // 現在時刻 → 5分刻みに切り捨て
        let base = max(record.createdAt, Date())
        let cal = Calendar.current
        let h = cal.component(.hour, from: base)
        let m = cal.component(.minute, from: base)
        self._selectedStep = State(initialValue: h * 12 + m / 5)
    }

    private var selectedDate: Date {
        let h = selectedStep / 12
        let m = (selectedStep % 12) * 5
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = h
        comps.minute = m
        comps.second = 0
        return cal.date(from: comps) ?? Date()
    }

    // 記録時刻を5分ブロック単位（秒を無視）で比較
    private var recordStep: Int {
        let cal = Calendar.current
        let h = cal.component(.hour, from: record.createdAt)
        let m = cal.component(.minute, from: record.createdAt)
        return h * 12 + m / 5
    }

    private var currentStep: Int {
        let cal = Calendar.current
        let now = Date()
        let h = cal.component(.hour, from: now)
        let m = cal.component(.minute, from: now)
        return h * 12 + m / 5
    }

    private var isValid: Bool {
        selectedStep >= recordStep
    }

    private var timeLabel: String {
        let h = selectedStep / 12
        let m = (selectedStep % 12) * 5
        return String(format: "%d:%02d", h, m)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(S.Record.settleTimeTitle)
                    .font(.headline)

                // Digital Crownで操作できるPicker
                Picker("", selection: $selectedStep) {
                    ForEach(0..<Self.totalSteps, id: \.self) { step in
                        let h = step / 12
                        let m = (step % 12) * 5
                        Text(String(format: "%d:%02d", h, m)).tag(step)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)

                if !isValid {
                    Text(S.Record.settleTimeInvalidPast)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }

                Button {
                    WKInterfaceDevice.current().play(.success)
                    onConfirm(selectedDate)
                    dismiss()
                } label: {
                    Text(S.Record.settleConfirm)
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!isValid)

                Button(S.Common.cancel) { dismiss() }
                    .buttonStyle(.bordered)
                    .font(.caption)
            }
            .padding(.horizontal, 4)
        }
    }
}
