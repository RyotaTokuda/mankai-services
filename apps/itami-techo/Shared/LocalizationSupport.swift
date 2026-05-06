import Foundation

/// アプリがサポートする言語
enum AppLanguage: String {
    case ja
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"

    /// 端末の言語設定から現在の表示言語を決定する（アプリ起動時に一度だけ評価）
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

/// 多言語文字列ルックアップ
/// - Parameters:
///   - ja: 日本語文字列（法務レビューの基準）
///   - en: English
///   - zhHans: 简体中文
///   - zhHant: 繁體中文
@inline(__always)
func L(_ ja: String, en: String, zhHans: String, zhHant: String) -> String {
    switch AppLanguage.current {
    case .ja:     return ja
    case .en:     return en
    case .zhHans: return zhHans
    case .zhHant: return zhHant
    }
}
