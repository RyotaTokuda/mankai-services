import UIKit

enum AppIcon: String, CaseIterable, Identifiable {
    case `default` = "AppIcon"
    case dark      = "AppIconDark"
    case minimal   = "AppIconMinimal"
    case colorBlue = "AppIconBlue"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default:   return L("デフォルト", en: "Default", zhHans: "默认", zhHant: "預設")
        case .dark:      return L("ダーク",     en: "Dark",    zhHans: "深色", zhHant: "深色")
        case .minimal:   return L("ミニマル",   en: "Minimal", zhHans: "简约", zhHant: "簡約")
        case .colorBlue: return L("ブルー",     en: "Blue",    zhHans: "蓝色", zhHant: "藍色")
        }
    }

    var alternateIconName: String? {
        self == .default ? nil : rawValue
    }
}

enum AppIconService {
    static var currentIcon: AppIcon {
        guard let name = UIApplication.shared.alternateIconName else { return .default }
        return AppIcon(rawValue: name) ?? .default
    }

    static func setIcon(_ icon: AppIcon, completion: ((Error?) -> Void)? = nil) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(icon.alternateIconName, completionHandler: completion)
    }
}
