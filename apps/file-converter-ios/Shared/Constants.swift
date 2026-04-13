import Foundation

enum AppConstants {
    static let appName = "ファイル変換"

    // MARK: - StoreKit 2 Product IDs

    static let plusMonthlyID = "fileconverter.plus.monthly"
    static let plusYearlyID = "fileconverter.plus.yearly"
    static let allProductIDs: Set<String> = [plusMonthlyID, plusYearlyID]
    static let subscriptionGroupID = "fileconverter.plus"

    // MARK: - URLs

    static let privacyPolicyURL = URL(string: "https://mankai.app/privacy")!
    static let termsOfServiceURL = URL(string: "https://mankai.app/terms")!
    static let supportURL = URL(string: "https://mankai.app/support")!
}
