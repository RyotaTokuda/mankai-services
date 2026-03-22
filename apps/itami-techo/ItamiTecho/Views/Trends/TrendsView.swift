import SwiftUI

/// iPhone: 傾向画面
struct TrendsView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    private var last14Days: [SymptomRecord] {
        recordStore.records(lastDays: 14)
    }

    var body: some View {
        NavigationStack {
            List {
                if last14Days.isEmpty {
                    Section {
                        Text(S.Common.trendHint)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section(S.Common.last14Days) {
                        LabeledContent("記録件数", value: "\(last14Days.count)件")
                        LabeledContent("服薬回数", value: "\(AnalysisHelper.medicationCount(from: last14Days))回")
                    }

                    Section(S.Trends.bySymptom) {
                        let counts = AnalysisHelper.symptomCounts(from: last14Days)
                        ForEach(counts, id: \.0) { name, count in
                            HStack {
                                Text(name)
                                Spacer()
                                Text("\(count)件")
                                    .foregroundStyle(.secondary)
                                let maxCount = counts.first?.1 ?? 1
                                Rectangle()
                                    .fill(Color.accentColor.opacity(0.3))
                                    .frame(width: CGFloat(count) / CGFloat(maxCount) * 60, height: 12)
                                    .cornerRadius(2)
                            }
                        }
                    }

                    Section(S.Trends.byTimeOfDay) {
                        ForEach(AnalysisHelper.timeOfDayCounts(from: last14Days), id: \.0) { label, count in
                            LabeledContent(label, value: "\(count)件")
                        }
                    }

                    Section(S.Common.detailView) {
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

                        NavigationLink {
                            ReportView()
                        } label: {
                            Label(S.Report.title, systemImage: "doc.text")
                        }
                    }
                }
            }
            .navigationTitle(S.Trends.title)
        }
    }
}
