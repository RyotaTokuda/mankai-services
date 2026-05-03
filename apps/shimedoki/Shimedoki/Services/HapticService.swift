import UIKit

enum HapticService {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap(style: HapticStyle = .normal) {
        switch style {
        case .gentle: lightImpact.impactOccurred()
        case .normal: mediumImpact.impactOccurred()
        case .strong: heavyImpact.impactOccurred()
        }
    }

    static func success() {
        notification.notificationOccurred(.success)
    }

    static func warning() {
        notification.notificationOccurred(.warning)
    }
}
