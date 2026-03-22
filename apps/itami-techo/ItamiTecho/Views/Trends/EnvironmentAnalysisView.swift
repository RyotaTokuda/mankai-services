import SwiftUI

/// iPhone: 環境分析画面
struct EnvironmentAnalysisView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    private var records: [SymptomRecord] {
        let days = planService.isPremium ? 90 : 14
        return recordStore.records(lastDays: days)
    }

    private var recordsWithPressure: [SymptomRecord] {
        records.filter { $0.environment?.pressure != nil }
    }

    var body: some View {
        List {
            if recordsWithPressure.isEmpty {
                Section {
                    Text(S.Common.trendHint)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section(S.Environment.pressure) {
                    ForEach(AnalysisHelper.pressureDistribution(from: records), id: \.0) { label, count in
                        LabeledContent(label, value: "\(count)件")
                    }
                    if AnalysisHelper.pressureDropCount(from: records) > 0 {
                        Text(S.Environment.hintPressure)
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.top, 4)
                    }
                }

                Section(S.Environment.weather) {
                    ForEach(AnalysisHelper.weatherCounts(from: records), id: \.0) { weather, count in
                        LabeledContent(weather, value: "\(count)件")
                    }
                }

                Section {
                    Text(S.Environment.hintGeneral)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(S.Environment.title)
    }
}
