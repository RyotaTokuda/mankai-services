import ActivityKit
import Foundation

struct ShimedokiActivityAttributes: ActivityAttributes {
    public typealias ContentState = ShimedokiActivityState

    var templateTitle: String
    var colorHex: String
    var totalSeconds: Int

    struct ShimedokiActivityState: Codable, Hashable {
        var remainingSeconds: Int
        var isPaused: Bool
        var isFinished: Bool

        var timeString: String {
            let mins = remainingSeconds / 60
            let secs = remainingSeconds % 60
            return String(format: "%d:%02d", mins, secs)
        }

        var progress: Double {
            // Sent from the app where we know total
            0.0
        }
    }
}
