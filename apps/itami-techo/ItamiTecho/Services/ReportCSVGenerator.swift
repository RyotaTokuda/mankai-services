import Foundation

/// 記録データを CSV 形式で出力する
/// 列定義は CLAUDE.md「通院向けレポート仕様 > CSV 列定義」を正とする
enum ReportCSVGenerator {
    static func generate(records: [SymptomRecord]) -> String {
        var lines: [String] = []

        lines.append(S.Report.csvHeaders.joined(separator: ","))

        let calendar = Calendar.current

        for r in records {
            let symptom = r.symptomType.map { S.Symptom.name(for: $0) } ?? r.customSymptomName ?? S.Symptom.custom
            let env = r.environment
            let health = r.healthSummary

            let durationMinutes: String = {
                guard let settled = r.settledAt else { return "" }
                return "\(Int(settled.timeIntervalSince(r.createdAt) / 60))"
            }()

            let weekdayIdx = calendar.component(.weekday, from: r.createdAt) - 1  // 0=日〜6=土
            let weekdayLabel = S.Common.weekdayLabelsSundayFirst[weekdayIdx]

            let hour = calendar.component(.hour, from: r.createdAt)
            let timeCategory: String = {
                switch hour {
                case 5..<12: return S.Trends.timeMorningShort
                case 12..<17: return S.Trends.timeAfternoonShort
                case 17..<21: return S.Trends.timeEveningShort
                default: return S.Trends.timeNightShort
                }
            }()

            var row: [String] = []
            row.append(r.createdAt.formatted(.iso8601))
            row.append(csvEscape(symptom))
            row.append("\(r.severity)")
            row.append(csvEscape(S.Severity.label(for: r.severity)))
            row.append(r.medicationTaken ? S.Common.boolYes : S.Common.boolNo)
            row.append(r.medicationTakenAt?.formatted(.iso8601) ?? "")
            row.append(r.settledAt?.formatted(.iso8601) ?? "")
            row.append(durationMinutes)
            row.append(csvEscape(r.settleCause?.label ?? ""))
            row.append(csvEscape(r.note ?? ""))
            row.append(r.sourceDevice == .watch ? S.Common.sourceWatch : S.Common.sourceiPhone)
            row.append(csvEscape(env?.weatherCondition ?? ""))
            row.append(env?.pressure.map { String(format: "%.1f", $0) } ?? "")
            row.append(env?.pressureTrend3h.map { String(format: "%.1f", $0) } ?? "")
            row.append(env?.temperature.map { String(format: "%.1f", $0) } ?? "")
            row.append(env?.humidity.map { String(format: "%.0f", $0) } ?? "")
            row.append(env?.airQualityIndex.map { "\($0)" } ?? "")
            row.append(env?.pm25.map { String(format: "%.1f", $0) } ?? "")
            row.append(health?.sleepDurationHours.map { String(format: "%.1f", $0) } ?? "")
            row.append(health?.restingHeartRate.map { String(format: "%.0f", $0) } ?? "")
            row.append(health?.stepCount.map { "\($0)" } ?? "")
            row.append(weekdayLabel)
            row.append(timeCategory)
            lines.append(row.joined(separator: ","))
        }

        return lines.joined(separator: "\n")
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
