import Foundation

/// 記録時点の環境データスナップショット
/// 基本は記録時に取得するが、WeatherKit 一時失敗時は24h以内に補完する
struct EnvironmentSnapshot: Codable {
    /// 天気状態（晴れ・曇り・雨など）
    var weatherCondition: String?

    /// 気圧 (hPa)
    var pressure: Double?

    /// 直近3時間の気圧変化量 (hPa)
    var pressureTrend3h: Double?

    /// 気温 (℃)
    var temperature: Double?

    /// 湿度 (%)
    var humidity: Double?

    /// 空気質指数 (AQI)
    var airQualityIndex: Int?

    /// PM2.5 (μg/m³)
    var pm25: Double?

    /// 記録時の概略位置
    var locationApprox: LocationApprox?

    // ── 補完制御 ─────────────────────────────────────────
    /// true = 位置はあるが天気データ未取得（補完対象）
    var needsBackfill: Bool?
    /// この時刻までに補完する（記録から24h後）。超過したら諦める
    var backfillDeadline: Date?
}

/// 市区町村レベルに丸めた位置情報
/// 精密な座標は保存しない（プライバシー配慮）
struct LocationApprox: Codable {
    var latitude: Double
    var longitude: Double
    /// 市区町村名（表示用）
    var city: String?
}
