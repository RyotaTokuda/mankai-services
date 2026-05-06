import SwiftUI
import CoreLocation

/// iPhone: 傾向ダッシュボード
/// 期間セレクター → サマリー → 日別バー → 症状 / 強さ / 時間帯 / 曜日のカード
struct TrendsView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    enum DashPeriod: CaseIterable, Hashable {
        case week, month, all
        var label: String {
            switch self { case .week: S.Trends.period7days
                          case .month: S.Trends.period30days
                          case .all: S.Trends.periodAll }
        }
        var days: Int {
            switch self { case .week: 7; case .month: 30; case .all: Int.max }
        }
    }

    @State private var selectedPeriod: DashPeriod = .week
    @State private var showingPaywall = false

    private var availablePeriods: [DashPeriod] {
        planService.isPremium ? [.week, .month, .all] : [.week, .all]
    }

    private var effectiveDays: Int {
        planService.isPremium ? selectedPeriod.days : min(selectedPeriod.days, 14)
    }

    private var records: [SymptomRecord] {
        recordStore.records(lastDays: effectiveDays)
    }

    var body: some View {
        NavigationStack {
            Group {
                if recordStore.records.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            periodPicker
                            if !planService.isPremium && selectedPeriod == .all {
                                freeLimitBanner
                            }
                            summaryCard
                            if selectedPeriod != .all {
                                dayChartCard
                            }
                            symptomCard
                            timeCard
                            dayOfWeekCard
                            weatherCard
                            pressureZoneCard
                            pressureChangeCard
                            detailLinksCard
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle(S.Trends.title)
            .sheet(isPresented: $showingPaywall) { PaywallView() }
        }
    }

    // MARK: - 期間セレクター

    private var periodPicker: some View {
        Picker("", selection: $selectedPeriod) {
            ForEach(availablePeriods, id: \.self) {
                Text($0.label).tag($0)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - 無料プラン制限バナー

    private var freeLimitBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
            Text(S.Trends.periodFree)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button(S.Trends.upgrade) { showingPaywall = true }
                .font(.caption)
                .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    // MARK: - サマリーカード

    private var summaryCard: some View {
        let medCount = AnalysisHelper.medicationCount(from: records)
        let avgMin   = AnalysisHelper.avgSettleMinutes(from: records)
        let calendar = Calendar.current
        let activeDays = Set(records.map { calendar.startOfDay(for: $0.createdAt) }).count

        return DashCard {
            HStack(spacing: 0) {
                SummaryCell(value: "\(records.count)", label: S.Trends.recordCount, color: .accentColor)
                Divider().frame(height: 48)
                SummaryCell(value: "\(medCount)", label: S.Record.medicationTaken, color: .orange)
                Divider().frame(height: 48)
                if let avg = avgMin {
                    SummaryCell(value: "\(avg)分", label: S.Trends.avgDuration, color: .green)
                } else {
                    SummaryCell(value: "\(activeDays)日", label: S.Trends.symptomDays, color: .purple)
                }
            }
        }
    }

    // MARK: - 日別バーチャート

    private var dayChartCard: some View {
        let summaries = AnalysisHelper.dailySummaries(from: records, days: selectedPeriod.days)
        let maxCount  = summaries.map(\.count).max() ?? 1

        return DashCard(title: S.Trends.dailyChart) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: selectedPeriod == .week ? 10 : 5) {
                    ForEach(summaries) { day in
                        DayBarColumn(summary: day, maxCount: maxCount,
                                     showLabel: selectedPeriod == .week || day.count > 0)
                    }
                }
                .padding(.horizontal, 4)
                .frame(minWidth: UIScreen.main.bounds.width - 64)
            }
            .frame(height: 100)
        }
    }

    // MARK: - 症状別カード

    private var symptomCard: some View {
        let counts   = AnalysisHelper.symptomCounts(from: records)
        let maxCount = counts.first?.1 ?? 1

        return DashCard(title: S.Trends.bySymptom) {
            VStack(spacing: 8) {
                ForEach(counts.prefix(6), id: \.0) { name, count in
                    MiniBarRow(label: name, count: count, maxCount: maxCount,
                               color: .accentColor)
                }
            }
        }
    }

    // MARK: - 時間帯別カード（プレミアム）

    @ViewBuilder
    private var timeCard: some View {
        if planService.isPremium {
            let counts     = AnalysisHelper.timeOfDayCounts(from: records)
            let maxCount   = counts.map(\.1).max() ?? 1
            let icons      = ["sun.rise", "sun.max", "sunset", "moon.stars"]
            let shortLabels = [S.Trends.timeMorningShort, S.Trends.timeAfternoonShort,
                               S.Trends.timeEveningShort, S.Trends.timeNightShort]

            DashCard(title: S.Trends.byTimeOfDay) {
                HStack(spacing: 0) {
                    ForEach(shortLabels.indices, id: \.self) { idx in
                        let count = idx < counts.count ? counts[idx].1 : 0
                        let ratio = maxCount > 0 ? Double(count) / Double(maxCount) : 0
                        VStack(spacing: 6) {
                            Image(systemName: icons[idx])
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 28, height: 60)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.orange.opacity(0.8))
                                    .frame(width: 28, height: max(4, 60 * ratio))
                            }
                            Text(shortLabels[idx]).font(.caption2)
                            Text("\(count)\(S.Trends.countSuffix)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        } else {
            lockedCard(title: S.Trends.byTimeOfDay)
        }
    }

    // MARK: - 天気別カード（プレミアム）

    @ViewBuilder
    private var weatherCard: some View {
        if planService.isPremium {
            let counts = AnalysisHelper.weatherCounts(from: records)
            DashCard(title: S.Trends.byWeather) {
                if counts.isEmpty {
                    envEmptyState
                } else {
                    let maxCount = counts.first?.1 ?? 1
                    VStack(spacing: 8) {
                        ForEach(counts.prefix(5), id: \.0) { name, count in
                            MiniBarRow(label: name, count: count, maxCount: maxCount, color: .cyan)
                        }
                    }
                }
            }
        } else {
            lockedCard(title: S.Trends.byWeather)
        }
    }

    // MARK: - 気圧帯別カード（プレミアム）

    @ViewBuilder
    private var pressureZoneCard: some View {
        if planService.isPremium {
            let dist = AnalysisHelper.pressureDistribution(from: records)
            DashCard(title: S.Trends.byPressureZone) {
                if dist.isEmpty {
                    Text(S.Trends.noEnvironmentData)
                        .font(.caption).foregroundStyle(.secondary)
                } else {
                    let maxCount = dist.map(\.1).max() ?? 1
                    VStack(spacing: 8) {
                        ForEach(dist, id: \.0) { name, count in
                            MiniBarRow(label: name, count: count, maxCount: maxCount, color: .indigo)
                        }
                    }
                }
            }
        } else {
            lockedCard(title: S.Trends.byPressureZone)
        }
    }

    // MARK: - 気圧変化カード（プレミアム）

    @ViewBuilder
    private var pressureChangeCard: some View {
        if planService.isPremium {
            let dropCount    = AnalysisHelper.pressureDropCount(from: records)
            let totalWithEnv = records.filter { $0.environment?.pressure != nil }.count
            DashCard(title: S.Trends.pressureChange) {
                if totalWithEnv == 0 {
                    envEmptyState
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        MiniBarRow(label: S.Trends.pressureDrop, count: dropCount,
                                   maxCount: totalWithEnv, color: .purple)
                        MiniBarRow(label: S.Trends.pressureNormal, count: totalWithEnv - dropCount,
                                   maxCount: totalWithEnv, color: Color(.systemGray3))
                    }
                }
            }
        } else {
            lockedCard(title: S.Trends.pressureChange)
        }
    }

    // MARK: - ロック済みカード共通

    private func lockedCard(title: String) -> some View {
        DashCard(title: title) {
            Button { showingPaywall = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                    Text(S.Trends.premiumFeatureTeaser)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 環境データ空状態

    /// 位置情報が拒否済みの場合のみ設定リンクを表示
    private var isLocationDenied: Bool {
        let status = CLLocationManager().authorizationStatus
        return status == .denied || status == .restricted
    }

    private var envEmptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(S.Trends.noEnvironmentData)
                .font(.caption)
                .foregroundStyle(.secondary)
            if isLocationDenied {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(S.Environment.noDataButton)
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    // MARK: - 曜日別カード

    @ViewBuilder
    private var dayOfWeekCard: some View {
        if planService.isPremium {
            let counts   = AnalysisHelper.dayOfWeekCounts(from: records)
            let maxCount = counts.map(\.1).max() ?? 1

            DashCard(title: S.Trends.byDayOfWeek) {
                HStack(spacing: 0) {
                    ForEach(counts.indices, id: \.self) { idx in
                        let label = counts[idx].0
                        let count = counts[idx].1
                        let isWeekend = S.Trends.weekendIndices.contains(idx)
                        let ratio = maxCount > 0 ? Double(count) / Double(maxCount) : 0
                        VStack(spacing: 4) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 28, height: 50)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isWeekend ? Color.purple.opacity(0.8) : Color.accentColor.opacity(0.8))
                                    .frame(width: 28, height: max(4, 50 * ratio))
                            }
                            Text(label)
                                .font(.caption2)
                                .fontWeight(isWeekend ? .bold : .regular)
                                .foregroundStyle(isWeekend ? .purple : .primary)
                            Text("\(count)")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        } else {
            lockedCard(title: S.Trends.byDayOfWeek)
        }
    }

    // MARK: - 詳細リンクカード

    private var detailLinksCard: some View {
        DashCard(title: S.Common.detailView) {
            VStack(spacing: 0) {
                if planService.isPremium {
                    NavigationLink { EnvironmentAnalysisView() } label: {
                        DetailLinkRow(label: S.Environment.title, icon: "cloud.sun")
                    }
                    Divider().padding(.leading, 44)
                    NavigationLink { HealthAnalysisView() } label: {
                        DetailLinkRow(label: S.Health.title, icon: "heart.text.square")
                    }
                    Divider().padding(.leading, 44)
                } else {
                    Button { showingPaywall = true } label: {
                        DetailLinkRow(label: S.Environment.title, icon: "cloud.sun", locked: true)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 44)
                    Button { showingPaywall = true } label: {
                        DetailLinkRow(label: S.Health.title, icon: "heart.text.square", locked: true)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 44)
                }
                NavigationLink { ReportView() } label: {
                    DetailLinkRow(label: S.Report.title, icon: "doc.text")
                }
            }
        }
    }

    // MARK: - 空状態

    private var emptyState: some View {
        ContentUnavailableView {
            Label(S.Trends.title, systemImage: "chart.line.uptrend.xyaxis")
        } description: {
            Text(S.Common.trendHint)
        }
    }
}

// MARK: - 共通カードコンテナ

private struct DashCard<Content: View>: View {
    var title: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - サマリーセル

private struct SummaryCell: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 日別バー列

private struct DayBarColumn: View {
    let summary: AnalysisHelper.DaySummary
    let maxCount: Int
    let showLabel: Bool

    private var barColor: Color {
        switch summary.maxSeverity {
        case 1: .green
        case 2: Color(red: 0.5, green: 0.8, blue: 0.2)
        case 3: .yellow
        case 4: .orange
        case 5: .red
        default: Color(.systemGray4)
        }
    }

    private var ratio: Double {
        maxCount > 0 ? Double(summary.count) / Double(maxCount) : 0
    }

    private var dateLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(summary.date) { return S.Common.today }
        return summary.date.formatted(.dateTime.month(.defaultDigits).day())
    }

    var body: some View {
        VStack(spacing: 4) {
            if summary.count > 0 {
                Text("\(summary.count)")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            } else {
                Text(" ")
                    .font(.system(size: 9))
            }
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 20, height: 60)
                if summary.count > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor.opacity(0.85))
                        .frame(width: 20, height: max(6, 60 * ratio))
                }
            }
            Text(showLabel ? dateLabel : "")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - 横バー行

private struct MiniBarRow: View {
    let label: String
    let count: Int
    let maxCount: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.subheadline)
                .lineLimit(1)
                .frame(width: 72, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.75))
                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(max(1, maxCount)))
                }
            }
            .frame(height: 14)
            Text("\(count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 28, alignment: .trailing)
        }
    }
}

// MARK: - 詳細リンク行

private struct DetailLinkRow: View {
    let label: String
    let icon: String
    var locked = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: locked ? "lock.fill" : icon)
                .font(.subheadline)
                .foregroundStyle(locked ? Color.secondary : Color.accentColor)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(locked ? .secondary : .primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
    }
}
