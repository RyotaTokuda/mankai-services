import WatchKit

enum WatchHapticService {
    /// 残り5分以上 — やさしい通知
    static func playWarning(style: HapticStyle) {
        let device = WKInterfaceDevice.current()
        switch style {
        case .gentle:
            device.play(.click)
        case .normal:
            device.play(.directionUp)
        case .strong:
            device.play(.directionUp)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                device.play(.directionUp)
            }
        }
    }

    /// 残り1分 — 少し強い通知
    static func playUrgent(style: HapticStyle) {
        let device = WKInterfaceDevice.current()
        switch style {
        case .gentle:
            device.play(.directionUp)
        case .normal:
            device.play(.notification)
        case .strong:
            device.play(.notification)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                device.play(.notification)
            }
        }
    }

    /// 終了 — 明確な通知
    static func playEnd(style: HapticStyle) {
        let device = WKInterfaceDevice.current()
        switch style {
        case .gentle:
            device.play(.notification)
        case .normal:
            device.play(.notification)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                device.play(.success)
            }
        case .strong:
            device.play(.notification)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                device.play(.notification)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                device.play(.success)
            }
        }
    }

    /// 操作フィードバック
    static func tap() {
        WKInterfaceDevice.current().play(.click)
    }
}
