import Foundation

enum AppConstants {
    // ── App Group ────────────────────────────────────────
    static let appGroupID = "group.com.mankai.itami-techo"

    // ── ファイル名 ───────────────────────────────────────
    static let recordsFileName = "records.json"
    static let recordsBackupFileName = "records.json.bak"
    static let customSymptomsFileName = "custom_symptoms.json"
    static let customMedicationsFileName = "custom_medications.json"
    static let settingsFileName = "settings.json"

    // ── StoreKit Product ID ──────────────────────────────
    static let monthlyProductID = "itamitecho.premium.monthly"
    static let yearlyProductID = "itamitecho.premium.yearly"
    static let subscriptionGroupID = "itamitecho.premium"

    // ── 通知 ─────────────────────────────────────────────
    static let notificationCategoryRecord = "ITAMITECHO_RECORD"
    static let maxDailyNotifications = 1
    static let maxWeeklyNotifications = 4

    // ── 課金導線トリガー ─────────────────────────────────
    static let paywallTriggerRecordCount = 5

    // ── App Group コンテナ URL ────────────────────────────
    static var sharedContainerURL: URL {
        if let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            return url
        }
        // App Group が利用できない場合（Simulator / テスト / entitlements 未設定）
        // ドキュメントディレクトリにフォールバック
        #if DEBUG
        print("[ItamiTecho] App Group container not available. Falling back to documents directory.")
        #else
        assertionFailure("[ItamiTecho] App Group container not available. Check entitlements.")
        #endif
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
