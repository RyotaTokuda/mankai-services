import SwiftUI

/// iPhone: 環境分析画面
/// 気圧・天気・空気質と記録の相関ヒントを表示
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

    /// 気圧帯別の記録件数
    private var pressureDistribution: [(String, Int)] {
        var low = 0, normal = 0, high = 0
        for r in recordsWithPressure {
            guard let p = r.environment?.pressure else { continue }
            switch p {
            case ..<1005: low += 1
            case 1005..<1020: normal += 1
            default: high += 1
            }
        }
        return [
            ("低気圧 (<1005hPa)", low),
            ("通常 (1005-1020hPa)", normal),
            ("高気圧 (>1020hPa)", high),
        ].filter { $0.1 > 0 }
    }

    /// 気圧下降時の記録件数
    private var pressureDropRecords: Int {
        recordsWithPressure.filter { ($0.environment?.pressureTrend3h ?? 0) < -2.0 }.count
    }

    var body: some View {
        List {
            if recordsWithPressure.isEmpty {
                Section {
                    Text("環境データ付きの記録が増えると分析できるようになります")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                // 気圧分布
                Section(S.Environment.pressure) {
                    ForEach(pressureDistribution, id: \.0) { label, count in
                        LabeledContent(label, value: "\(count)件")
                    }
                    if pressureDropRecords > 0 {
                        Text(S.Environment.hintPressure)
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.top, 4)
                    }
                }

                // 天気別
                Section(S.Environment.weather) {
                    let weatherCounts = Dictionary(grouping: records.compactMap { $0.environment?.weatherCondition }, by: { $0 })
                        .mapValues(\.count)
                        .sorted { $0.value > $1.value }
                    ForEach(weatherCounts.prefix(5), id: \.key) { weather, count in
                        LabeledContent(weather, value: "\(count)件")
                    }
                }

                // 注意書き
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
