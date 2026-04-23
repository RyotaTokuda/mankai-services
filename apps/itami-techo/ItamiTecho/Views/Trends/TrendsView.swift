import SwiftUI

/// iPhone: 傾向画面
struct TrendsView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    @State private var showingPaywall = false

    private var records: [SymptomRecord] {
        recordStore.records(lastDays: planService.isPremium ? 90 : 14)
    }

    var body: some View {
        NavigationStack {
            List {
                if records.isEmpty {
                    Section {
                        Text(S.Common.trendHint)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // ── 集計期間 + 基本カウント ──
                    Section {
                        HStack {
                            Image(systemName: planService.isPremium ? "chart.bar.fill" : "lock")
                                .foregroundStyle(planService.isPremium ? Color.accentColor : .secondary)
                            Text(planService.isPremium ? S.Trends.periodPremium : S.Trends.periodFree)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if !planService.isPremium {
                                Button(S.Trends.upgrade) { showingPaywall = true }
                                    .font(.caption)
                                    .buttonStyle(.bordered)
                            }
                        }
                        LabeledContent(S.Trends.recordCount, value: "\(records.count)件")
                        LabeledContent(S.Trends.medicationCount, value: "\(AnalysisHelper.medicationCount(from: records))回")
                        if let avg = AnalysisHelper.avgSettleMinutes(from: records) {
                            LabeledContent(S.Trends.avgDuration, value: "\(avg)分")
                        }
                    }

                    // ── 症状別 ──
                    Section(S.Trends.bySymptom) {
                        let counts = AnalysisHelper.symptomCounts(from: records)
                        let maxCount = counts.first?.1 ?? 1
                        ForEach(counts, id: \.0) { name, count in
                            BarRow(label: name, count: count, maxCount: maxCount,
                                   color: .accentColor, labelWidth: 60)
                        }
                    }

                    // ── 強さの分布 ──
                    Section(S.Trends.severityDistribution) {
                        let dist = AnalysisHelper.severityDistribution(from: records)
                        let maxSev = dist.map(\.1).max() ?? 1
                        ForEach(dist.reversed(), id: \.0) { label, count in
                            BarRow(label: label, count: count, maxCount: maxSev,
                                   color: .red, labelWidth: 80)
                        }
                    }

                    // ── 時間帯別 ──
                    Section(S.Trends.byTimeOfDay) {
                        let counts = AnalysisHelper.timeOfDayCounts(from: records)
                        let maxTime = counts.map(\.1).max() ?? 1
                        ForEach(counts, id: \.0) { label, count in
                            BarRow(label: label, count: count, maxCount: maxTime,
                                   color: .orange, labelWidth: 80)
                        }
                    }

                    // ── 曜日別（プレミアム） ──
                    Section {
                        if planService.isPremium {
                            let counts = AnalysisHelper.dayOfWeekCounts(from: records)
                            let maxDay = counts.map(\.1).max() ?? 1
                            ForEach(counts, id: \.0) { label, count in
                                BarRow(label: label, count: count, maxCount: maxDay,
                                       color: .purple, labelWidth: 24,
                                       isWeekend: label == "土" || label == "日")
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.fill").foregroundStyle(.secondary)
                                    Text(S.Trends.dayOfWeekLocked).foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption).foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack {
                            Text(S.Trends.byDayOfWeek)
                            if !planService.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }

                    // ── 詳細分析へのリンク ──
                    Section(S.Common.detailView) {
                        if planService.isPremium {
                            NavigationLink {
                                EnvironmentAnalysisView()
                            } label: {
                                Label(S.Environment.title, systemImage: "cloud.sun")
                            }
                            NavigationLink {
                                HealthAnalysisView()
                            } label: {
                                Label(S.Health.title, systemImage: "heart.text.square")
                            }
                        } else {
                            LockedRow(label: S.Environment.title, icon: "cloud.sun") {
                                showingPaywall = true
                            }
                            LockedRow(label: S.Health.title, icon: "heart.text.square") {
                                showingPaywall = true
                            }
                        }

                        NavigationLink {
                            ReportView()
                        } label: {
                            Label(S.Report.title, systemImage: "doc.text")
                        }
                    }
                }
            }
            .navigationTitle(S.Trends.title)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - BarRow

private struct BarRow: View {
    let label: String
    let count: Int
    let maxCount: Int
    let color: Color
    var labelWidth: CGFloat = 80
    var isWeekend: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .frame(minWidth: labelWidth, alignment: .leading)
                .fontWeight(isWeekend ? .bold : .regular)
                .foregroundStyle(isWeekend ? color : .primary)
            Rectangle()
                .fill(color.opacity(0.35))
                .frame(width: CGFloat(count) / CGFloat(max(1, maxCount)) * 80, height: 10)
                .cornerRadius(3)
            Spacer()
            Text("\(count)件")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

// MARK: - LockedRow

private struct LockedRow: View {
    let label: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(label, systemImage: icon).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
