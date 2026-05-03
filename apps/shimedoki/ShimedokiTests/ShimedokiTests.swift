import XCTest
@testable import Shimedoki

final class ShimedokiTests: XCTestCase {

    // MARK: - Template

    func testDefaultTemplatesCount() {
        let templates = DefaultTemplates.create()
        XCTAssertEqual(templates.count, 6)
    }

    func testDefaultTemplateCategories() {
        let templates = DefaultTemplates.create()
        let categories = Set(templates.map(\.category))
        XCTAssertTrue(categories.contains(.oneOnOne))
        XCTAssertTrue(categories.contains(.sales))
        XCTAssertTrue(categories.contains(.meeting))
        XCTAssertTrue(categories.contains(.chat))
        XCTAssertTrue(categories.contains(.focus))
    }

    func testTemplateAlertOffsets() {
        let template = Template(
            title: "テスト",
            durationMinutes: 30,
            category: .meeting,
            alertOffsets: [300, 60]
        )
        XCTAssertEqual(template.alertOffsets, [300, 60])
    }

    func testDefaultTemplateColors() {
        let templates = DefaultTemplates.create()
        // 全テンプレにカラーHexが設定されている
        for t in templates {
            XCTAssertTrue(t.colorHex.hasPrefix("#"), "colorHex must start with #: \(t.colorHex)")
            XCTAssertEqual(t.colorHex.count, 7, "colorHex must be 7 chars: \(t.colorHex)")
        }
    }

    // MARK: - PlanLimits (existing)

    func testFreeTemplateLimitIs3() {
        XCTAssertEqual(PlanLimits.templateLimit(isPro: false), 3)
    }

    func testPlusTemplateLimitIsUnlimited() {
        XCTAssertEqual(PlanLimits.templateLimit(isPro: true), Int.max)
    }

    func testFreeHistoryDaysIs7() {
        XCTAssertEqual(PlanLimits.historyDays(isPro: false), 7)
    }

    func testPlusHistoryDaysIsUnlimited() {
        XCTAssertEqual(PlanLimits.historyDays(isPro: true), Int.max)
    }

    func testFreeCannotCustomizeAlertOffsets() {
        XCTAssertFalse(PlanLimits.canCustomizeAlertOffsets(isPro: false))
    }

    func testPlusCanCustomizeAlertOffsets() {
        XCTAssertTrue(PlanLimits.canCustomizeAlertOffsets(isPro: true))
    }

    // MARK: - PlanLimits (new Plus features)

    func testFreePlanCannotUseLiveActivity() {
        XCTAssertFalse(PlanLimits.canUseLiveActivity(isPro: false))
    }

    func testPlusPlanCanUseLiveActivity() {
        XCTAssertTrue(PlanLimits.canUseLiveActivity(isPro: true))
    }

    func testFreePlanCannotUseCustomIcon() {
        XCTAssertFalse(PlanLimits.canUseCustomIcon(isPro: false))
    }

    func testPlusPlanCanUseCustomIcon() {
        XCTAssertTrue(PlanLimits.canUseCustomIcon(isPro: true))
    }

    func testFreePlanCannotUseWidget() {
        XCTAssertFalse(PlanLimits.canUseWidget(isPro: false))
    }

    func testPlusPlanCanUseWidget() {
        XCTAssertTrue(PlanLimits.canUseWidget(isPro: true))
    }

    func testFreePlanCannotUseWeeklySummary() {
        XCTAssertFalse(PlanLimits.canUseWeeklySummary(isPro: false))
    }

    func testPlusPlanCanUseWeeklySummary() {
        XCTAssertTrue(PlanLimits.canUseWeeklySummary(isPro: true))
    }

    func testFreePlanCannotUseSessionNote() {
        XCTAssertFalse(PlanLimits.canUseSessionNote(isPro: false))
    }

    func testPlusPlanCanUseSessionNote() {
        XCTAssertTrue(PlanLimits.canUseSessionNote(isPro: true))
    }

    // MARK: - SessionLog (existing)

    func testSessionLogInitDefaults() {
        let session = SessionLog(templateId: UUID(), source: .watch)
        XCTAssertEqual(session.extendedCount, 0)
        XCTAssertFalse(session.completed)
        XCTAssertNil(session.endedAt)
        XCTAssertNil(session.note)
    }

    // MARK: - SessionLog note (new)

    func testSessionLogNoteIsNilByDefault() {
        let session = SessionLog(templateId: UUID())
        XCTAssertNil(session.note)
    }

    func testSessionLogNoteCanBeSet() {
        let session = SessionLog(templateId: UUID(), note: "決定事項: 次回は水曜")
        XCTAssertEqual(session.note, "決定事項: 次回は水曜")
    }

    func testSessionLogCodableWithNote() throws {
        let session = SessionLog(
            templateId: UUID(),
            extendedCount: 1,
            completed: true,
            source: .phone,
            note: "テストメモ"
        )
        let data = try JSONEncoder.appEncoder.encode(session)
        let decoded = try JSONDecoder.appDecoder.decode(SessionLog.self, from: data)

        XCTAssertEqual(session.id, decoded.id)
        XCTAssertEqual(decoded.note, "テストメモ")
        XCTAssertEqual(decoded.extendedCount, 1)
        XCTAssertTrue(decoded.completed)
    }

    func testSessionLogCodableWithoutNote() throws {
        let session = SessionLog(templateId: UUID())
        let data = try JSONEncoder.appEncoder.encode(session)
        let decoded = try JSONDecoder.appDecoder.decode(SessionLog.self, from: data)
        XCTAssertNil(decoded.note)
    }

    // MARK: - SessionStore stats

    func testSessionStoreCountSinceDate() {
        let tid  = UUID()
        let now  = Date()
        let past = now.addingTimeInterval(-3 * 86400)

        let sessions: [SessionLog] = [
            makeSession(templateId: tid, daysAgo: 0, durationMinutes: 30, completed: true),
            makeSession(templateId: tid, daysAgo: 0, durationMinutes: 45, completed: true),
            makeSession(templateId: tid, daysAgo: 4, durationMinutes: 30, completed: true), // 範囲外
        ]
        let store = SessionStore(preloaded: sessions)
        XCTAssertEqual(store.sessionCount(since: past), 2)
    }

    func testSessionStoreTotalMinutes() {
        let tid  = UUID()
        let past = Date().addingTimeInterval(-86400)

        let sessions: [SessionLog] = [
            makeSession(templateId: tid, daysAgo: 0, durationMinutes: 30, completed: true),
            makeSession(templateId: tid, daysAgo: 0, durationMinutes: 45, completed: true),
        ]
        let store = SessionStore(preloaded: sessions)
        XCTAssertEqual(store.totalMinutes(since: past), 75)
    }

    func testSessionStoreCountExcludesIncomplete() {
        let tid  = UUID()
        let past = Date().addingTimeInterval(-86400)

        let sessions: [SessionLog] = [
            makeSession(templateId: tid, daysAgo: 0, durationMinutes: 30, completed: true),
            makeSession(templateId: tid, daysAgo: 0, durationMinutes: 30, completed: false), // 未完了は除外
        ]
        let store = SessionStore(preloaded: sessions)
        XCTAssertEqual(store.sessionCount(since: past), 1)
    }

    // MARK: - TemplateStore Sorting

    func testSortingPinnedFirst() {
        let store = TemplateStore()
        let pinned   = Template(title: "Pinned",   durationMinutes: 30, category: .meeting, isPinned: true)
        let unpinned = Template(title: "Unpinned", durationMinutes: 30, category: .meeting, isPinned: false)
        store.add(unpinned)
        store.add(pinned)

        let sorted = store.sortedTemplates()
        if let first = sorted.first(where: { $0.id == pinned.id || $0.id == unpinned.id }) {
            XCTAssertTrue(first.isPinned || first.id == pinned.id)
        }
    }

    // MARK: - Template Codable

    func testTemplateCodable() throws {
        let template = Template(
            title: "テスト会議",
            durationMinutes: 45,
            category: .sales,
            alertOffsets: [300, 60],
            hapticStyle: .strong,
            colorHex: "#D94020",
            isPinned: true
        )

        let data = try JSONEncoder.appEncoder.encode(template)
        let decoded = try JSONDecoder.appDecoder.decode(Template.self, from: data)

        XCTAssertEqual(template.id, decoded.id)
        XCTAssertEqual(template.title, decoded.title)
        XCTAssertEqual(template.durationMinutes, decoded.durationMinutes)
        XCTAssertEqual(template.category, decoded.category)
        XCTAssertEqual(template.alertOffsets, decoded.alertOffsets)
        XCTAssertEqual(template.hapticStyle, decoded.hapticStyle)
        XCTAssertEqual(template.colorHex, decoded.colorHex)
        XCTAssertEqual(template.isPinned, decoded.isPinned)
    }

    // MARK: - Localization

    func testStringsNotEmpty() {
        XCTAssertFalse(S.App.name.isEmpty)
        XCTAssertFalse(S.Scene.navTitle.isEmpty)
        XCTAssertFalse(S.History.navTitle.isEmpty)
        XCTAssertFalse(S.Settings.navTitle.isEmpty)
        XCTAssertFalse(S.Paywall.legalText.isEmpty)
    }

    func testSceneMinutesFormatting() {
        let result = S.Scene.minutes(30)
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("30"))
    }

    func testNotificationWeeklySummaryFormat() {
        let result = S.Notification.weeklySummary(sessions: 5, minutes: 120)
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("5"))
        XCTAssertTrue(result.contains("120"))
    }

    // MARK: - Helpers

    private func makeSession(
        templateId: UUID,
        daysAgo: Int,
        durationMinutes: Int = 30,
        completed: Bool = true
    ) -> SessionLog {
        let start = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        let end   = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return SessionLog(
            templateId: templateId,
            startedAt: start,
            endedAt: end,
            completed: completed
        )
    }
}
