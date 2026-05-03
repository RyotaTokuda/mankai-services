import Foundation

enum AppLanguage: String {
    case ja
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"

    static let current: AppLanguage = {
        for lang in Locale.preferredLanguages {
            if lang.hasPrefix("zh-Hant") || lang.hasPrefix("zh-TW")
                || lang.hasPrefix("zh-HK") || lang.hasPrefix("zh-MO") { return .zhHant }
            if lang.hasPrefix("zh") { return .zhHans }
            if lang.hasPrefix("en") { return .en }
            if lang.hasPrefix("ja") { return .ja }
        }
        return .ja
    }()
}

@inline(__always)
func L(_ ja: String, en: String, zhHans: String, zhHant: String) -> String {
    switch AppLanguage.current {
    case .ja:     return ja
    case .en:     return en
    case .zhHans: return zhHans
    case .zhHant: return zhHant
    }
}
