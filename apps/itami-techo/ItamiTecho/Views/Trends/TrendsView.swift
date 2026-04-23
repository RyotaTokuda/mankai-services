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
                    // ── 集計期間 ──
                    Section {
                        HStack {
                            Image(systemName: planService.isPremium ? "chart.bar.fill" : "lock")
                                .foregroundStyle(planService.isPremium ? Color.accentColor : .secondary)
                            Text(planService.isPremium ? "直近90日間の傾向" : "直近14日間の傾向（無料プラン）")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if !planService.isPremium {
                                Button("アップグレード") { showingPaywall = true }
                                    .font(.caption)
                                    .buttonStyle(.bordered)
                            }
                        }
                        LabeledContent("記録件数", value: "\(records.count)件")
                        LabeledContent("服薬回数", value: "\(AnalysisHelper.medicationCount(from: records))回")
                    }

                    // ── 症状別 ──
                    Section(S.Trends.bySymptom) {
                        let counts = AnalysisHelper.symptomCounts(from: records)
                        let maxCount = counts.first?.1 ?? 1
                        ForEach(counts, id: \.0) { name, count in
                            HStack(spacing: 8) {
                                Text(name)
                                    .frame(minWidth: 60, alignment: .leading)
                                Rectangle()
                                    .fill(Color.accentColor.opacity(0.35))
                                    .frame(width: CGFloat(count) / CGFloat(maxCount) * 80, height: 10)
                                    .cornerRadius(3)
                                Spacer()
                                Text("\(count)件")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    }

                    // ── 時間帯別 ──
                    Section(S.Trends.byTimeOfDay) {
                        let counts = AnalysisHelper.timeOfDayCounts(from: records)
                        let maxTime = counts.map(\.1).max() ?? 1
                        ForEach(counts, id: \.0) { label, count in
                            HStack(spacing: 8) {
                                Text(label)
                                    .frame(minWidth: 80, alignment: .leading)
                                Rectangle()
                                    .fill(Color.orange.opacity(0.35))
                                    .frame(width: CGFloat(count) / CGFloat(maxTime) * 80, height: 10)
                                    .cornerRadius(3)
                                Spacer()
                                Text("\(count)件")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    }

                    // ── 曜日別（プレミアム） ──
                    Section {
                        if planService.isPremium {
                            let counts = AnalysisHelper.dayOfWeekCounts(from: records)
                            let maxDay = counts.map(\.1).max().flatMap { $0 > 0 ? $0 : nil } ?? 1
                            ForEach(counts, id: \.0) { label, count in
                                HStack(spacing: 8) {
                                    Text(label)
                                        .frame(width: 24, alignment: .center)
                                        .fontWeight(isWeekend(label) ? .bold : .regular)
                                        .foregroundStyle(isWeekend(label) ? Color.accentColor : .primary)
                                    Rectangle()
                                        .fill(Color.purple.opacity(0.35))
                                        .frame(width: CGFloat(count) / CGFloat(maxDay) * 80, height: 10)
                                        .cornerRadius(3)
                                    Spacer()
                                    Text("\(count)件")
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.secondary)
                                    Text("曜日別傾向はプレミアム機能です")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack {
                            Text(S.Trends.byDayOfWeek)
                            if !planService.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
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
                            Button { showingPaywall = true } label: {
                                HStack {
                                    Label(S.Environment.title, systemImage: "cloud.sun")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            Button { showingPaywall = true } label: {
                                HStack {
                                    Label(S.Health.title, systemImage: "heart.text.square")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
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

    private func isWeekend(_ label: String) -> Bool {
        label == "土" || label == "日"
    }
}
