import WatchKit

enum WatchHapticService {
    /// 残り5分以上 — やさしい通知
    static func playWarning(style: HapticStyle, count: Int = 1) {
        let device = WKInterfaceDevice.current()
        let type: WKHapticType = style == .gentle ? .click : .directionUp
        play(device: device, type: type, count: count)
    }

    /// 残り1分 — 少し強い通知
    static func playUrgent(style: HapticStyle, count: Int = 1) {
        let device = WKInterfaceDevice.current()
        let type: WKHapticType = style == .gentle ? .directionUp : .notification
        play(device: device, type: type, count: count)
    }

    /// 終了 — 明確な通知
    static func playEnd(style: HapticStyle, count: Int = 1) {
        let device = WKInterfaceDevice.current()
        let clamped = max(1, min(3, count))
        for i in 0..<clamped {
            let delay = Double(i) * 0.35
            let type: WKHapticType = (i == clamped - 1) ? .success : .notification
            if delay == 0 {
                device.play(type)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    device.play(type)
                }
            }
        }
    }

    private static func play(device: WKInterfaceDevice, type: WKHapticType, count: Int) {
        let clamped = max(1, min(3, count))
        for i in 0..<clamped {
            let delay = Double(i) * 0.3
            if delay == 0 {
                device.play(type)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    device.play(type)
                }
            }
        }
    }

    /// 操作フィードバック
    static func tap() {
        WKInterfaceDevice.current().play(.click)
    }
}
