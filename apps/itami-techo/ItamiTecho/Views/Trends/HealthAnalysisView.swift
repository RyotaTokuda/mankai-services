import SwiftUI

/// iPhone: Health分析画面
struct HealthAnalysisView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService
    @Environment(HealthService.self) private var healthService

    private var records: [SymptomRecord] {
        recordStore.records(lastDays: planService.isPremium ? 90 : 14)
    }

    private var recordsWithHealth: [SymptomRecord] {
        records.filter { $0.healthSummary != nil }
    }

    var body: some View {
        List {
            if recordsWithHealth.isEmpty {
                if !healthService.isAuthorized {
                    // HealthKit 未連携 → 設定へ誘導
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(S.Health.connectTitle, systemImage: "heart.text.square.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)

                            Text(S.Health.connectBody)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button {
                                Task { await healthService.requestAuthorization() }
                            } label: {
                                Text(S.Health.connectButton)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    // 連携済みだがデータなし
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(S.Health.noDataYet)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(S.Common.trendHint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                if let sleep = AnalysisHelper.sleepAnalysis(from: recordsWithHealth) {
                    Section(S.Health.sleep) {
                        LabeledContent(S.Health.shortSleepRecord, value: "\(sleep.shortSleepCount)件")
                        LabeledContent(S.Health.normalSleepRecord, value: "\(sleep.normalSleepCount)件")
                        if sleep.shortSleepCount > sleep.normalSleepCount {
                            Text(S.Health.hintSleep)
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.top, 4)
                        }
                    }
                }

                if let hr = AnalysisHelper.heartRateAnalysis(from: recordsWithHealth) {
                    Section(S.Health.heartRate) {
                        LabeledContent(S.Health.highHRRecord, value: "\(hr.highHRCount)件")
                        LabeledContent(S.Health.normalHRRecord, value: "\(hr.normalHRCount)件")
                        if hr.highHRCount > hr.normalHRCount / 2 {
                            Text(S.Health.hintHeartRate)
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.top, 4)
                        }
                    }
                }

                Section(S.Health.steps) {
                    let avgSteps = recordsWithHealth.compactMap { $0.healthSummary?.stepCount }
                    if !avgSteps.isEmpty {
                        let avg = avgSteps.reduce(0, +) / avgSteps.count
                        LabeledContent(S.Health.avgStepsRecord, value: "\(avg)歩")
                    }
                }

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
