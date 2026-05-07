import SwiftUI
import WatchKit

@Observable
final class SessionViewModel {
    var template: Template
    var remainingSeconds: Int
    var isPaused: Bool = false
    var isFinished: Bool = false
    var extendedCount: Int = 0

    private(set) var sessionLog: SessionLog?
    private var timer: Timer?
    private var endDate: Date
    private var pausedRemainingSeconds: Int?
    private var extendedSession: WKExtendedRuntimeSession?

    init(template: Template) {
        self.template = template
        self.remainingSeconds = template.durationMinutes * 60
        self.endDate = Date().addingTimeInterval(TimeInterval(template.durationMinutes * 60))
    }

    // MARK: - Lifecycle

    func start(sessionStore: SessionStore, templateStore: TemplateStore) {
        sessionLog = sessionStore.startSession(templateId: template.id, source: .watch)
        templateStore.markUsed(template)
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        scheduleNotifications()
        startTimer()
        startExtendedSession()
    }

    func pause() {
        isPaused = true
        pausedRemainingSeconds = remainingSeconds
        timer?.invalidate()
        timer = nil
        cancelNotifications()
        stopExtendedSession()
    }

    func resume() {
        isPaused = false
        if let remaining = pausedRemainingSeconds {
            remainingSeconds = remaining
        }
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        scheduleNotifications()
        startTimer()
        startExtendedSession()
    }

    func extend(minutes: Int = 5) {
        extendedCount += 1
        remainingSeconds += minutes * 60
        endDate = endDate.addingTimeInterval(TimeInterval(minutes * 60))

        if let sessionId = sessionLog?.id {
            // SessionStore の incrementExtension は外部から呼ぶ
            cancelNotifications()
            scheduleNotifications()
        }

        if isFinished {
            isFinished = false
            startTimer()
            startExtendedSession()
        }
    }

    func stop(sessionStore: SessionStore, completed: Bool) {
        timer?.invalidate()
        timer = nil
        cancelNotifications()
        stopExtendedSession()

        if let id = sessionLog?.id {
            sessionStore.endSession(id: id, completed: completed)
        }
        isFinished = true
    }

    func cleanup() {
        timer?.invalidate()
        timer = nil
        cancelNotifications()
        stopExtendedSession()
    }

    // MARK: - Display

    var timeString: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var progress: Double {
        let total = Double(template.durationMinutes * 60 + extendedCount * 5 * 60)
        guard total > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / total)
    }

    // MARK: - Private

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, !self.isPaused else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.checkAlertOffsets()
            } else {
                self.onTimeUp()
            }
        }
    }

    private func checkAlertOffsets() {
        for offset in template.alertOffsets {
            if remainingSeconds == offset {
                playHaptic(for: offset)
            }
        }
    }

    private func onTimeUp() {
        timer?.invalidate()
        timer = nil
        isFinished = true
        WatchHapticService.playEnd(style: template.hapticStyle, count: template.hapticCount)
    }

    private func playHaptic(for offset: Int) {
        if offset >= 300 {
            WatchHapticService.playWarning(style: template.hapticStyle, count: template.hapticCount)
        } else {
            WatchHapticService.playUrgent(style: template.hapticStyle, count: template.hapticCount)
        }
    }

    // MARK: - Notifications

    private func scheduleNotifications() {
        guard let sessionId = sessionLog?.id.uuidString else { return }
        NotificationService.scheduleSessionAlerts(
            sessionId: sessionId,
            templateTitle: template.title,
            endDate: endDate,
            alertOffsets: template.alertOffsets
        )
    }

    private func cancelNotifications() {
        guard let sessionId = sessionLog?.id.uuidString else { return }
        NotificationService.cancelSessionAlerts(sessionId: sessionId)
    }

    // MARK: - Extended Runtime Session

    private func startExtendedSession() {
        let session = WKExtendedRuntimeSession()
        session.start()
        extendedSession = session
    }

    private func stopExtendedSession() {
        extendedSession?.invalidate()
        extendedSession = nil
    }
}
