import Foundation
import os

/// 解析イベントを一元管理
/// MVP ではログ出力のみ。将来的に Firebase Analytics 等に差し替え可能
enum AnalyticsService {
    private static let logger = Logger(subsystem: "com.mankai.shimedoki", category: "analytics")

    enum Event: String {
        case onboardingCompleted     = "onboarding_completed"
        case templateStarted         = "template_started"
        case templateCompleted       = "template_completed"
        case templateExtended        = "template_extended"
        case templateCreated         = "template_created"
        case paywallViewed           = "paywall_viewed"
        case paywallConverted        = "paywall_converted"
        case calendarConnectTapped   = "calendar_connect_tapped"
        case historyUnlockTapped     = "history_unlock_tapped"
    }

    static func log(_ event: Event, parameters: [String: String] = [:]) {
        var message = "[\(event.rawValue)]"
        if !parameters.isEmpty {
            let params = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            message += " \(params)"
        }
        logger.info("\(message)")

        // TODO: Firebase Analytics, Amplitude 等に差し替え
        // Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}
