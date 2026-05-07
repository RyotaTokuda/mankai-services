import UIKit

enum HapticService {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap(style: HapticStyle = .normal, count: Int = 1) {
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .gentle: generator = lightImpact
        case .normal: generator = mediumImpact
        case .strong: generator = heavyImpact
        }
        let clamped = max(1, min(3, count))
        for i in 0..<clamped {
            let delay = Double(i) * 0.25
            if delay == 0 {
                generator.impactOccurred()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    generator.impactOccurred()
                }
            }
        }
    }

    static func success() {
        notification.notificationOccurred(.success)
    }

    static func warning() {
        notification.notificationOccurred(.warning)
    }
}
