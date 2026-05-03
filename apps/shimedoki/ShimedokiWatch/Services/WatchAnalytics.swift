import os

/// Watch 側の解析ログ（iOS の AnalyticsService と同等）
enum WatchAnalytics {
    private static let logger = Logger(subsystem: "com.mankai.shimedoki.watch", category: "analytics")

    static func log(_ event: String, params: [String: String] = [:]) {
        var message = "[\(event)]"
        if !params.isEmpty {
            let p = params.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            message += " \(p)"
        }
        logger.info("\(message)")
    }
}
