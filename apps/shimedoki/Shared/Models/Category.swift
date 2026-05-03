import Foundation

enum TemplateCategory: String, Codable, CaseIterable, Identifiable {
    case meeting    = "meeting"
    case oneOnOne   = "one_on_one"
    case sales      = "sales"
    case chat       = "chat"
    case focus      = "focus"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .meeting:  return S.SceneCategory.meeting
        case .oneOnOne: return S.SceneCategory.oneOnOne
        case .sales:    return S.SceneCategory.sales
        case .chat:     return S.SceneCategory.chat
        case .focus:    return S.SceneCategory.focus
        }
    }

    var symbolName: String {
        switch self {
        case .meeting:  return "person.3.fill"
        case .oneOnOne: return "person.2.fill"
        case .sales:    return "briefcase.fill"
        case .chat:     return "bubble.left.and.bubble.right.fill"
        case .focus:    return "brain.head.profile.fill"
        }
    }
}
