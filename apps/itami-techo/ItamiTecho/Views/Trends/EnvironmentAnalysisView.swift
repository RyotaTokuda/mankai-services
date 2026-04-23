import SwiftUI

/// iPhone: 環境分析画面
struct EnvironmentAnalysisView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService
    @Environment(EnvironmentService.self) private var environmentService

    private var records: [SymptomRecord] {
        recordStore.records(lastDays: planService.isPremium ? 90 : 14)
    }

    private var recordsWithPressure: [SymptomRecord] {
        records.filter { $0.environment?.pressure != nil }
    }

    private var isLocationDenied: Bool {
        let status = environmentService.locationService.authorizationStatus
        return status == .denied || status == .restricted
    }

    var body: some View {
        List {
            if recordsWithPressure.isEmpty {
                if isLocationDenied {
                    // 位置情報が拒否されている → 設定を開く誘導
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("天気・気圧データがありません", systemImage: "cloud.sun.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)

                            Text("天気・気圧との関係を見るには、位置情報の許可が必要です。気圧はセンサーで取得しているため、位置を許可しなくても気圧データは収集されます。")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("設定で位置情報を許可する")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    // 記録が少ないまたは位置未設定
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("環境データがまだ記録されていません")
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
