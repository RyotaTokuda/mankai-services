import Foundation

/// 記録データを CSV 形式で出力する
enum ReportCSVGenerator {
    static func generate(records: [SymptomRecord]) -> String {
        var lines: [String] = []

        // ヘッダー
        lines.append([
            "日時",
            "症状",
            "強さ",
            "強さラベル",
            "服薬",
            "服薬時刻",
            "落ち着いた時刻",
            "メモ",
            "記録元",
            "天気",
            "気圧(hPa)",
            "気圧変化3h(hPa)",
            "気温(℃)",
            "湿度(%)",
            "空気質(AQI)",
            "PM2.5",
            "睡眠(時間)",
            "安静時心拍(bpm)",
            "歩数",
        ].joined(separator: ","))

        // データ行
        for r in records {
            let symptom = r.symptomType.map { S.Symptom.name(for: $0) } ?? r.customSymptomName ?? "カスタム"
            let env = r.environment
            let health = r.healthSummary

            var row: [String] = []
            row.append(r.createdAt.formatted(.iso8601))
            row.append(csvEscape(symptom))
            row.append("\(r.severity)")
            row.append(csvEscape(S.Severity.label(for: r.severity)))
            row.append(r.medicationTaken ? "はい" : "いいえ")
            row.append(r.medicationTakenAt?.formatted(.iso8601) ?? "")
            row.append(r.settledAt?.formatted(.iso8601) ?? "")
            row.append(csvEscape(r.note ?? ""))
            row.append(r.sourceDevice == .watch ? "Watch" : "iPhone")
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
