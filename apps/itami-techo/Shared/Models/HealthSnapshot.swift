import Foundation

/// 記録時点の Health データサマリー
/// 診断には使わず、記録との並列表現・傾向表示に留める
struct HealthSnapshot: Codable {
    /// 前夜の睡眠時間 (時間)
    var sleepDurationHours: Double?

    /// 直近の平均心拍 (bpm)
    var avgHeartRate: Double?

    /// 安静時心拍 (bpm)
    var restingHeartRate: Double?

    /// 心拍変動 (ms)
    var heartRateVariability: Double?

    /// 当日の歩数
    var stepCount: Int?

    /// 呼吸数 (回/分)
    var respiratoryRate: Double?

    /// 当日ワークアウト実施有無
    var hadWorkout: Bool?
}
