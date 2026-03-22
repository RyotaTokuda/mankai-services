import SwiftUI

/// iPhone: Health分析画面
/// 睡眠・心拍・歩数と記録の傾向を並列表示
struct HealthAnalysisView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    private var records: [SymptomRecord] {
        let days = planService.isPremium ? 90 : 14
        return recordStore.records(lastDays: days)
    }

    private var recordsWithHealth: [SymptomRecord] {
        records.filter { $0.healthSummary != nil }
    }

    /// 睡眠時間と記録の関係
    private var sleepAnalysis: (shortSleepCount: Int, normalSleepCount: Int)? {
        let withSleep = recordsWithHealth.filter { $0.healthSummary?.sleepDurationHours != nil }
        guard withSleep.count >= 3 else { return nil }
        let shortSleep = withSleep.filter { ($0.healthSummary?.sleepDurationHours ?? 8) < 6 }.count
        let normalSleep = withSleep.count - shortSleep
        return (shortSleep, normalSleep)
    }

    /// 安静時心拍と記録の関係
    private var heartRateAnalysis: (highHRCount: Int, normalHRCount: Int)? {
        let withHR = recordsWithHealth.filter { $0.healthSummary?.restingHeartRate != nil }
        guard withHR.count >= 3 else { return nil }
        let avgRHR = withHR.compactMap { $0.healthSummary?.restingHeartRate }.reduce(0, +) / Double(withHR.count)
        let highHR = withHR.filter { ($0.healthSummary?.restingHeartRate ?? 0) > avgRHR + 5 }.count
        let normalHR = withHR.count - highHR
        return (highHR, normalHR)
    }

    var body: some View {
        List {
            if recordsWithHealth.isEmpty {
                Section {
                    Text("Health連携データ付きの記録が増えると分析できるようになります")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                // 睡眠
                if let sleep = sleepAnalysis {
                    Section(S.Health.sleep) {
                        LabeledContent("6時間未満の日の記録", value: "\(sleep.shortSleepCount)件")
                        LabeledContent("6時間以上の日の記録", value: "\(sleep.normalSleepCount)件")
                        if sleep.shortSleepCount > sleep.normalSleepCount {
                            Text(S.Health.hintSleep)
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.top, 4)
                        }
                    }
                }

                // 心拍
                if let hr = heartRateAnalysis {
                    Section(S.Health.heartRate) {
                        LabeledContent("安静時心拍高めの日の記録", value: "\(hr.highHRCount)件")
                        LabeledContent("通常の日の記録", value: "\(hr.normalHRCount)件")
                        if hr.highHRCount > hr.normalHRCount / 2 {
                            Text(S.Health.hintHeartRate)
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.top, 4)
                        }
                    }
                }

                // 歩数サマリー
                Section(S.Health.steps) {
                    let avgSteps = recordsWithHealth.compactMap { $0.healthSummary?.stepCount }
                    if !avgSteps.isEmpty {
                        let avg = avgSteps.reduce(0, +) / avgSteps.count
                        LabeledContent("記録日の平均歩数", value: "\(avg)歩")
                    }
                }

                // 注意書き
                Section {
                    Text(S.Legal.disclaimer4)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(S.Health.title)
    }
}
