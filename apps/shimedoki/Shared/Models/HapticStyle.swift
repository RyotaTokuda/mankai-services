import Foundation

enum HapticStyle: String, Codable, CaseIterable, Identifiable {
    case gentle  = "gentle"
    case normal  = "normal"
    case strong  = "strong"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gentle: return S.Haptic.gentle
        case .normal: return S.Haptic.normal
        case .strong: return S.Haptic.strong
        }
    }
}
