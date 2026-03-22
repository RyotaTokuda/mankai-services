import Foundation

/// 傾向分析・環境分析・Health分析の集計ロジック
/// View から切り出して共通化する
enum AnalysisHelper {

    // MARK: - 傾向分析

    /// 症状別件数（降順）
    static func symptomCounts(from records: [SymptomRecord]) -> [(String, Int)] {
        var counts: [String: Int] = [:]
        for r in records {
            counts[r.displayName, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    /// 時間帯別件数
    static func timeOfDayCounts(from records: [SymptomRecord]) -> [(String, Int)] {
        let calendar = Calendar.current
        var morning = 0, afternoon = 0, evening = 0, night = 0
        for record in records {
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

    /// 強さ分布
    static func severityDistribution(from records: [SymptomRecord]) -> [(String, Int)] {
        var dist = [Int: Int]()
        for r in records { dist[r.severity, default: 0] += 1 }
        return (1...5).map { (S.Severity.label(for: $0), dist[$0] ?? 0) }
    }

    /// 服薬回数
    static func medicationCount(from records: [SymptomRecord]) -> Int {
        records.filter(\.medicationTaken).count
    }

    /// 落ち着くまでの平均時間（分）
    static func avgSettleMinutes(from records: [SymptomRecord]) -> Int? {
        let durations = records.compactMap { r -> TimeInterval? in
            guard let settled = r.settledAt else { return nil }
            return settled.timeIntervalSince(r.createdAt)
        }
        guard !durations.isEmpty else { return nil }
        return Int(durations.reduce(0, +) / Double(durations.count) / 60)
    }

    // MARK: - 環境分析

    /// 気圧帯別の記録件数
    static func pressureDistribution(from records: [SymptomRecord]) -> [(String, Int)] {
        var low = 0, normal = 0, high = 0
        for r in records {
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
    static func pressureDropCount(from records: [SymptomRecord]) -> Int {
        records.filter { ($0.environment?.pressureTrend3h ?? 0) < -2.0 }.count
    }

    /// 天気別件数（降順、上位5件）
    static func weatherCounts(from records: [SymptomRecord]) -> [(String, Int)] {
        let grouped = Dictionary(grouping: records.compactMap { $0.environment?.weatherCondition }, by: { $0 })
            .mapValues(\.count)
            .sorted { $0.value > $1.value }
        return Array(grouped.prefix(5))
    }

    // MARK: - Health分析

    /// 睡眠分析
    static func sleepAnalysis(from records: [SymptomRecord]) -> (shortSleepCount: Int, normalSleepCount: Int)? {
        let withSleep = records.filter { $0.healthSummary?.sleepDurationHours != nil }
        guard withSleep.count >= 3 else { return nil }
        let shortSleep = withSleep.filter { ($0.healthSummary?.sleepDurationHours ?? 8) < 6 }.count
        return (shortSleep, withSleep.count - shortSleep)
    }

    /// 安静時心拍分析
    static func heartRateAnalysis(from records: [SymptomRecord]) -> (highHRCount: Int, normalHRCount: Int)? {
        let withHR = records.filter { $0.healthSummary?.restingHeartRate != nil }
        guard withHR.count >= 3 else { return nil }
        let avgRHR = withHR.compactMap { $0.healthSummary?.restingHeartRate }.reduce(0, +) / Double(withHR.count)
        let highHR = withHR.filter { ($0.healthSummary?.restingHeartRate ?? 0) > avgRHR + 5 }.count
        return (highHR, withHR.count - highHR)
    }
}
