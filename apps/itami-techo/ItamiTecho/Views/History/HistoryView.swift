import SwiftUI

/// iPhone: 履歴画面
/// 今日の記録 + 直近14日 + カレンダー切り替え
struct HistoryView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    @State private var showingCalendar = false
    @State private var selectedRecord: SymptomRecord?

    /// 表示対象の記録（プランに応じた日数制限）
    private var visibleRecords: [SymptomRecord] {
        recordStore.records(lastDays: planService.historyDays)
    }

    /// 日付ごとにグルーピング
    private var groupedRecords: [(String, [SymptomRecord])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: visibleRecords) { record in
            calendar.startOfDay(for: record.createdAt)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (dateLabel($0.key), $0.value.sorted { $0.createdAt > $1.createdAt }) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleRecords.isEmpty {
                    ContentUnavailableView {
                        Label(S.History.noRecords, systemImage: "tray")
                    }
                } else {
                    List {
                        ForEach(groupedRecords, id: \.0) { dateLabel, records in
                            Section(dateLabel) {
                                ForEach(records) { record in
                                    RecordRow(record: record)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedRecord = record
                                        }
                                }
                            }
                        }

                        // 無料プランの履歴制限メッセージ
                        if !planService.isPremium {
                            Section {
                                Text(S.History.olderRecords)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(S.History.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCalendar.toggle()
                    } label: {
                        Image(systemName: showingCalendar ? "list.bullet" : "calendar")
                    }
                }
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
            .sheet(isPresented: $showingCalendar) {
                CalendarView()
            }
        }
    }

    private func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return S.History.today
        }
        return date.formatted(.dateTime.month().day().weekday())
    }
}

// MARK: - 記録行

struct RecordRow: View {
    let record: SymptomRecord

    var body: some View {
        HStack {
            // 強さインジケーター
            Circle()
                .fill(severityColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(symptomName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 6) {
                    Text(record.createdAt.formatted(.dateTime.hour().minute()))
                    Text(S.Severity.label(for: record.severity))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                if record.medicationTaken {
                    Image(systemName: "pills.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                if record.settledAt != nil {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                if record.sourceDevice == .watch {
                    Image(systemName: "applewatch")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(symptomName)、\(S.Severity.label(for: record.severity))")
    }

    private var symptomName: String {
        record.symptomType.map { S.Symptom.name(for: $0) }
            ?? record.customSymptomName
            ?? S.Symptom.custom
    }

    private var severityColor: Color {
        switch record.severity {
        case 1: .green
        case 2: .yellow
        case 3: .orange
        case 4: .red
        case 5: .purple
        default: .orange
        }
    }
}
