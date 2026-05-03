import EventKit

enum CalendarService {
    private static let store = EKEventStore()

    /// カレンダーへのアクセスを要求
    static func requestAccess() async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    /// 今日の予定を取得
    static func todayEvents() -> [EKEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = store.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        return store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
    }

    /// 直近の予定を取得（次の N 件）
    static func upcomingEvents(limit: Int = 10) -> [EKEvent] {
        let now = Date()
        guard let endDate = Calendar.current.date(byAdding: .day, value: 7, to: now) else {
            return []
        }

        let predicate = store.predicateForEvents(
            withStart: now,
            end: endDate,
            calendars: nil
        )
        return store.events(matching: predicate)
            .filter { !$0.isAllDay && $0.startDate > now }
            .prefix(limit)
            .map { $0 }
    }

    /// カレンダーイベントからテンプレを推定
    static func suggestTemplate(
        for event: EKEvent,
        templates: [Template]
    ) -> Template? {
        let title = event.title?.lowercased() ?? ""
        let durationMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)

        // タイトルからカテゴリを推定
        if title.contains("1on1") || title.contains("1:1") {
            return templates.first { $0.category == .oneOnOne }
        }
        if title.contains("面接") || title.contains("interview") {
            return templates.first { $0.category == .meeting && $0.durationMinutes == 60 }
        }
        if title.contains("商談") || title.contains("営業") {
            return templates.first { $0.category == .sales }
        }

        // 時間が最も近いテンプレを返す
        return templates.min(by: {
            abs($0.durationMinutes - durationMinutes) < abs($1.durationMinutes - durationMinutes)
        })
    }

    static var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
}
