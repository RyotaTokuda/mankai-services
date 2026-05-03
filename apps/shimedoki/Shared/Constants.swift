import Foundation

enum AppConstants {
    static let appGroupID = "group.com.mankai.shimedoki"
    static let templatesFileName = "templates.json"
    static let sessionsFileName = "sessions.json"

    /// StoreKit 2 Product IDs
    static let plusMonthlyID = "shimedoki.plus.monthly"
    static let plusYearlyID = "shimedoki.plus.yearly"
    static let allProductIDs: Set<String> = [plusMonthlyID, plusYearlyID]

    /// App Group の共有ディレクトリ
    static var sharedContainerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
