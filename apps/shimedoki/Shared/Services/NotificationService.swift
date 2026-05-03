import UserNotifications

enum NotificationService {
    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// セッション中の通知をスケジュール
    static func scheduleSessionAlerts(
        sessionId: String,
        templateTitle: String,
        endDate: Date,
        alertOffsets: [Int]
    ) {
        let center = UNUserNotificationCenter.current()

        // 既存のセッション通知を削除
        let identifiers = alertOffsets.map { "session-\(sessionId)-\($0)" }
            + ["session-\(sessionId)-end"]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        // 各アラートオフセットの通知
        for offset in alertOffsets {
            let alertDate = endDate.addingTimeInterval(TimeInterval(-offset))
            guard alertDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = S.Notification.appName
            let minutes = offset / 60
            content.body = minutes > 0
                ? S.Notification.minutesLeft(minutes, scene: templateTitle)
                : S.Notification.soonEnd(scene: templateTitle)
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: alertDate.timeIntervalSinceNow,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "session-\(sessionId)-\(offset)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // 終了通知
        let endContent = UNMutableNotificationContent()
        endContent.title = S.Notification.appName
        endContent.body = S.Notification.timeToEnd(scene: templateTitle)
        endContent.sound = .default

        if endDate.timeIntervalSinceNow > 0 {
            let endTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: endDate.timeIntervalSinceNow,
                repeats: false
            )
            let endRequest = UNNotificationRequest(
                identifier: "session-\(sessionId)-end",
                content: endContent,
                trigger: endTrigger
            )
            center.add(endRequest)
        }
    }

    /// セッションの通知を全て削除
    static func cancelSessionAlerts(sessionId: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [])
        // セッションIDを含む通知を全て削除
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix("session-\(sessionId)") }
                .map(\.identifier)
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
