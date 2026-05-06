import SwiftUI

/// 落ち着いた時刻を10分刻みで入力するシート
/// - デフォルト: 現在時刻を10分刻みに切り捨て
/// - バリデーション: 記録時刻より前・現在時刻より後は確認ボタンを無効化
/// - 解消要因の選択も同一シートで行う
struct SettleTimePickerView: View {
    let record: SymptomRecord
    let onConfirm: (Date, SettleCause?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedHour: Int
    @State private var selectedMinuteIndex: Int
    @State private var selectedCause: SettleCause?

    private static let minuteSteps = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]

    init(record: SymptomRecord, onConfirm: @escaping (Date, SettleCause?) -> Void) {
        self.record = record
        self.onConfirm = onConfirm

        // 現在時刻を10分刻みに切り捨て、記録時刻を下回らないよう調整
        let base = max(record.createdAt, Date())
        let cal = Calendar.current
        let h = cal.component(.hour, from: base)
        let m = cal.component(.minute, from: base)
        self._selectedHour = State(initialValue: h)
        self._selectedMinuteIndex = State(initialValue: min(m / 5, 11))
        self._selectedCause = State(initialValue: record.settleCause)
    }

    // MARK: - 選択した日時

    private var selectedDate: Date {
        let cal = Calendar.current
        // 今日の日付 + 選択した時:分
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = selectedHour
        comps.minute = Self.minuteSteps[selectedMinuteIndex]
        comps.second = 0
        return cal.date(from: comps) ?? Date()
    }

    // 秒を無視して10分ブロック単位で比較
    private var selectedMinutes: Int { selectedHour * 60 + Self.minuteSteps[selectedMinuteIndex] }

    private var recordMinutes: Int {
        let cal = Calendar.current
        let h = cal.component(.hour, from: record.createdAt)
        let m = cal.component(.minute, from: record.createdAt)
        return h * 60 + (m / 5) * 5
    }

    private var currentMinutes: Int {
        let cal = Calendar.current
        let now = Date()
        let h = cal.component(.hour, from: now)
        let m = cal.component(.minute, from: now)
        return h * 60 + (m / 5) * 5
    }

    private var validationError: String? {
        if selectedMinutes < recordMinutes { return S.Record.settleTimeInvalidPast }
        return nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── 時刻ピッカー ──
                HStack(spacing: 0) {
                    Picker(selection: $selectedHour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text("\(h)時").tag(h)
                        }
                    } label: { EmptyView() }
                    .pickerStyle(.wheel)

                    Picker(selection: $selectedMinuteIndex) {
                        ForEach(Self.minuteSteps.indices, id: \.self) { i in
                            Text(String(format: "%02d分", Self.minuteSteps[i])).tag(i)
                        }
                    } label: { EmptyView() }
                    .pickerStyle(.wheel)
                }
                .frame(height: 150)

                if let error = validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.bottom, 8)
                }

                Divider()

                // ── 解消要因 ──
                VStack(alignment: .leading, spacing: 10) {
                    Text(S.Record.whySettled)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(SettleCause.allCases) { cause in
                            causeButton(cause)
                        }
                    }
                }
                .padding()

                Spacer()

                // ── 確認ボタン ──
                Button {
                    onConfirm(selectedDate, selectedCause)
                    dismiss()
                } label: {
                    Text(S.Record.settleConfirm)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(validationError != nil)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(S.Record.settleTimeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(S.Common.cancel) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func causeButton(_ cause: SettleCause) -> some View {
        let isSelected = selectedCause == cause
        return Button {
            selectedCause = isSelected ? nil : cause
        } label: {
            Label(cause.label, systemImage: cause.icon)
                .font(.subheadline)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isSelected ? Color.green.opacity(0.15) : Color(.systemGray6))
                .foregroundStyle(isSelected ? .green : .primary)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}
