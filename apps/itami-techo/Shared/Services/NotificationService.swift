import Foundation
import UserNotifications
import CoreLocation

/// 予兆通知・文脈通知サービス
/// 1日最大1回、週最大4回の通知制限を守る
@Observable
final class NotificationService {
    private(set) var isAuthorized = false
    private let fileURL: URL
    private let coordinator = NSFileCoordinator()

    /// 通知履歴（頻度制御用）
    private var sentDates: [Date] = []

    init() {
        self.fileURL = AppConstants.sharedContainerURL
            .appendingPathComponent("notification_history.json")
        loadHistory()
    }

    // MARK: - 権限

    func requestAuthorization() async -> Bool {
        do {
            isAuthorized = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
            return isAuthorized
        } catch {
            print("[NotificationService] auth error: \(error)")
            return false
        }
    }

    // MARK: - 予兆通知の判定と送信

    /// 気圧予報から通知が必要か判定
    func evaluateAndNotify(forecast: [PressureForecastPoint]) async {
        guard isAuthorized, canSendToday(), canSendThisWeek() else { return }

        // 今後6時間で3hPa以上の低下があるか
        guard let current = forecast.first,
              let sixHoursLater = forecast.first(where: {
                  $0.date > Date().addingTimeInterval(5 * 3600)
              })
        else { return }

        let drop = current.pressure - sixHoursLater.pressure
        if drop >= 3.0 {
            await sendNotification(
                title: S.App.name,
                body: S.Notification.pressureChange
            )
        }
    }

    /// 天気急変通知
    func notifyWeatherChange() async {
        guard isAuthorized, canSendToday(), canSendThisWeek() else { return }
        await sendNotification(
            title: S.App.name,
            body: S.Notification.weatherChange
        )
    }

    // MARK: - 通知送信

    private func sendNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = AppConstants.notificationCategoryRecord

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 即時
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            recordSent()
        } catch {
            print("[NotificationService] send error: \(error)")
        }
    }

    // MARK: - 頻度制御

    private func canSendToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let todayCount = sentDates.filter { $0 >= today }.count
        return todayCount < AppConstants.maxDailyNotifications
    }

    private func canSendThisWeek() -> Bool {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        let weekCount = sentDates.filter { $0 >= weekAgo }.count
        return weekCount < AppConstants.maxWeeklyNotifications
    }

    private func recordSent() {
        sentDates.append(Date())
        // 30日以上前の履歴を削除
        let cutoff = Date().addingTimeInterval(-30 * 24 * 3600)
        sentDates.removeAll { $0 < cutoff }
        saveHistory()
    }

    // MARK: - 永続化

    private func loadHistory() {
        var readError: NSError?
        coordinator.coordinate(readingItemAt: fileURL, options: [], error: &readError) { url in
            guard FileManager.default.fileExists(atPath: url.path) else { return }
            do {
                let data = try Data(contentsOf: url)
                self.sentDates = try JSONDecoder.appDecoder.decode([Date].self, from: data)
            } catch {
                self.sentDates = []
            }
        }
    }

    private func saveHistory() {
        var writeError: NSError?
        coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: &writeError) { url in
            do {
                let data = try JSONEncoder.appEncoder.encode(sentDates)
                try data.write(to: url, options: .atomic)
            } catch {
                print("[NotificationService] save error: \(error)")
            }
        }
    }
}
