import SwiftUI

/// iPhone: カレンダー表示
/// 月表示で記録がある日にドットを表示、日付タップで詳細
struct CalendarView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var selectedRecord: SymptomRecord?

    private var calendar: Calendar { Calendar.current }

    /// 表示月の日付一覧
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    /// ロケールの週開始日を考慮した曜日ヘッダー
    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...]) + Array(symbols[..<start])
    }

    /// 月初の空白日数（ロケールの週開始日を考慮）
    private var leadingEmptyDays: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    /// 特定日の記録件数
    private func recordCount(for date: Date) -> Int {
        recordStore.records.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
    }

    /// 選択日の記録
    private var recordsForSelectedDate: [SymptomRecord] {
        recordStore.records
            .filter { calendar.isDate($0.createdAt, inSameDayAs: selectedDate) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // ── 月ナビゲーション ──
                HStack {
                    Button {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Text(displayedMonth.formatted(.dateTime.year().month()))
                        .font(.headline)

                    Spacer()

                    Button {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                // ── 曜日ヘッダー ──
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(orderedWeekdaySymbols, id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // ── カレンダーグリッド ──
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // 月初の空白（ロケールの週開始日を考慮）
                    ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                        Text("")
                    }

                    ForEach(daysInMonth, id: \.self) { date in
                        let count = recordCount(for: date)
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)

                        Button {
                            selectedDate = date
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.callout)
                                    .fontWeight(isToday ? .bold : .regular)

                                if count > 0 {
                                    HStack(spacing: 1) {
                                        ForEach(0..<min(count, 3), id: \.self) { _ in
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                } else {
                                    Spacer().frame(height: 4)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(isSelected ? Color.accentColor.opacity(0.15) : .clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(isToday ? Color.accentColor : .primary)
                    }
                }
                .padding(.horizontal)

                // ── 選択日の記録一覧 ──
                if recordsForSelectedDate.isEmpty {
                    Text(S.History.noRecords)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(recordsForSelectedDate) { record in
                        RecordRow(record: record)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                            }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }
}
