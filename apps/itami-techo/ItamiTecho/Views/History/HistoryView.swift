import SwiftUI

/// iPhone: 履歴画面
/// 今日の記録 + 直近14日 + カレンダー切り替え
struct HistoryView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    @State private var showingCalendar = false
    @State private var selectedRecord: SymptomRecord?
    @State private var settlingRecord: SymptomRecord?
    @State private var showingReport = false

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
                        // ── 通院CTA（5件以上記録があれば表示） ──
                        if recordStore.records.count >= 5 {
                            Section {
                                Button {
                                    showingReport = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.title3)
                                            .foregroundStyle(Color.accentColor)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(S.Report.doctorCTA)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)
                                            Text(S.Report.doctorCTABody)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if !planService.isPremium {
                                            Text(S.Settings.planBadge)
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 3)
                                                .background(Color.accentColor)
                                                .cornerRadius(6)
                                        }
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        ForEach(groupedRecords, id: \.0) { dateLabel, records in
                            Section(dateLabel) {
                                ForEach(records) { record in
                                    RecordRow(
                                        record: record,
                                        onSettle: record.settledAt == nil
                                            ? { settlingRecord = record }
                                            : nil
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedRecord = record }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        if record.settledAt == nil {
                                            Button {
                                                settlingRecord = record
                                            } label: {
                                                Label(S.Record.settled, systemImage: "heart.fill")
                                            }
                                            .tint(.green)
                                        }
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
            .sheet(isPresented: $showingReport) {
                NavigationStack { ReportView(isModal: true) }
            }
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
    /// 未解消の記録を「落ち着いた」にするコールバック。nil の場合はボタン非表示
    var onSettle: (() -> Void)? = nil

    private var isUnresolved: Bool { record.settledAt == nil }

    var body: some View {
        HStack {
            // 強さインジケーター（未解消は彩度高め、解消済みは淡色）
            Circle()
                .fill(isUnresolved ? record.severityColor : record.severityColor.opacity(0.4))
                .frame(width: 10, height: 10)
                .overlay(
                    isUnresolved ? Circle().stroke(record.severityColor, lineWidth: 1.5) : nil
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(record.displayName)
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

            HStack(spacing: 6) {
                if record.medicationTaken {
                    Image(systemName: "pills.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if let settle = onSettle, isUnresolved {
                    // 未解消：タップで「落ち着いた」を記録できるボタン
                    Button {
                        settle()
                    } label: {
                        VStack(spacing: 1) {
                            Image(systemName: "heart")
                                .font(.caption)
                            Text(S.Record.settledButton)
                                .font(.system(size: 8))
                        }
                        .foregroundStyle(Color.green.opacity(0.8))
                        .padding(6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(S.Record.settled)
                } else {
                    Image(systemName: record.settledAt != nil ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundStyle(record.settledAt != nil ? Color.green : Color.secondary.opacity(0.35))
                }

                if record.sourceDevice == .watch {
                    Image(systemName: "applewatch")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.displayName)、\(S.Severity.label(for: record.severity))")
    }
}
