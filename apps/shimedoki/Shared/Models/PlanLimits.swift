import Foundation

enum PlanLimits {
    // MARK: - Free
    static let freeTemplateLimit = 3
    static let freeHistoryDays = 7
    /// 無料版は固定プリセットのみ（残り5分 + 残り1分）
    static let freeAlertOffsets: [Int] = [300, 60]

    // MARK: - Plus
    static let plusTemplateLimit = Int.max
    static let plusHistoryDays = Int.max

    static func templateLimit(isPro: Bool) -> Int {
        isPro ? plusTemplateLimit : freeTemplateLimit
    }

    static func historyDays(isPro: Bool) -> Int {
        isPro ? plusHistoryDays : freeHistoryDays
    }

    static func historyStartDate(isPro: Bool) -> Date? {
        guard !isPro else { return nil }
        return Calendar.current.date(byAdding: .day, value: -freeHistoryDays, to: Date())
    }

    static func canCustomizeAlertOffsets(isPro: Bool) -> Bool {
        isPro
    }

    static func canConnectCalendar(isPro: Bool) -> Bool {
        isPro
    }

    static func canUseSiriShortcut(isPro: Bool) -> Bool {
        isPro
    }

    static func canUseLiveActivity(isPro: Bool) -> Bool {
        isPro
    }

    static func canUseCustomIcon(isPro: Bool) -> Bool {
        isPro
    }

    static func canUseWidget(isPro: Bool) -> Bool {
        isPro
    }

    static func canUseWeeklySummary(isPro: Bool) -> Bool {
        isPro
    }

    static func canUseSessionNote(isPro: Bool) -> Bool {
        isPro
    }
}
