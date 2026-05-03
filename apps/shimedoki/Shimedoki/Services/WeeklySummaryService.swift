import UserNotifications
import Foundation

enum WeeklySummaryService {
    private static let notificationID = "shimedoki.weekly.summary"
    private static let enabledKey     = "shimedoki.weeklySummary.enabled"

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    // MARK: - Schedule

    /// 統計付きで通知をスケジュール（Toggle ON 時に呼ぶ）
    static func scheduleWithStats(sessionCount: Int, totalMinutes: Int) {
        guard isEnabled else { return }
        schedule(body: S.Notification.weeklySummary(sessions: sessionCount, minutes: totalMinutes))
    }

    static func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    // MARK: - Private

    private static func schedule(body: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])

        var components = DateComponents()
        components.weekday = 1  // Sunday
        components.hour = 20
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = S.Notification.appName
        content.body  = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
