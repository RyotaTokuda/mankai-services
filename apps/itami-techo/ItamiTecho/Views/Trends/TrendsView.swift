import SwiftUI

/// iPhone: 傾向画面（Phase 3 で本格実装）
/// Phase 1 では基本集計のみ表示
struct TrendsView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    private var last14Days: [SymptomRecord] {
        recordStore.records(lastDays: 14)
    }

    /// 症状別件数
    private var symptomCounts: [(String, Int)] {
        var counts: [String: Int] = [:]
        for record in last14Days {
            let name = record.symptomType.map { S.Symptom.name(for: $0) }
                ?? record.customSymptomName
                ?? S.Symptom.custom
            counts[name, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    /// 時間帯別件数
    private var timeOfDayCounts: [(String, Int)] {
        let calendar = Calendar.current
        var morning = 0, afternoon = 0, evening = 0, night = 0
        for record in last14Days {
            let hour = calendar.component(.hour, from: record.createdAt)
            switch hour {
            case 5..<12: morning += 1
            case 12..<17: afternoon += 1
            case 17..<21: evening += 1
            default: night += 1
            }
        }
        return [
            ("朝 (5-12時)", morning),
            ("昼 (12-17時)", afternoon),
            ("夕 (17-21時)", evening),
            ("夜 (21-5時)", night),
        ].filter { $0.1 > 0 }
    }

    var body: some View {
        NavigationStack {
            List {
                if last14Days.isEmpty {
                    Section {
                        Text("記録が増えると傾向が見えてきます")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // 直近14日の概要
                    Section("直近14日") {
                        LabeledContent("記録件数", value: "\(last14Days.count)件")
                        LabeledContent("服薬回数", value: "\(last14Days.filter(\.medicationTaken).count)回")
                    }

                    // 症状別
                    Section(S.Trends.bySymptom) {
                        ForEach(symptomCounts, id: \.0) { name, count in
                            HStack {
                                Text(name)
                                Spacer()
                                Text("\(count)件")
                                    .foregroundStyle(.secondary)
                                // 簡易バー
                                let maxCount = symptomCounts.first?.1 ?? 1
                                Rectangle()
                                    .fill(Color.accentColor.opacity(0.3))
                                    .frame(width: CGFloat(count) / CGFloat(maxCount) * 60, height: 12)
                                    .cornerRadius(2)
                            }
                        }
                    }

                    // 時間帯別
                    Section(S.Trends.byTimeOfDay) {
                        ForEach(timeOfDayCounts, id: \.0) { label, count in
                            LabeledContent(label, value: "\(count)件")
                        }
                    }

                    // 詳細分析への導線
                    Section("詳しく見る") {
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
