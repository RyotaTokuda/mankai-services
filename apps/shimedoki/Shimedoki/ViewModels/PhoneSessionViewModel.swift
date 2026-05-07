import Foundation
import Observation
import ActivityKit

@Observable
final class PhoneSessionViewModel: Identifiable {
    let id = UUID()
    var template: Template
    var remainingSeconds: Int
    var isPaused: Bool = false
    var isFinished: Bool = false
    var extendedCount: Int = 0

    private(set) var sessionLog: SessionLog?
    private var timer: Timer?
    private var endDate: Date
    private var activity: Activity<ShimedokiActivityAttributes>?
    private var totalSeconds: Int
    private var liveActivityEnabled: Bool = false

    init(template: Template) {
        self.template = template
        self.remainingSeconds = template.durationMinutes * 60
        self.totalSeconds     = template.durationMinutes * 60
        self.endDate = Date().addingTimeInterval(TimeInterval(template.durationMinutes * 60))
    }

    // MARK: - Lifecycle

    func start(sessionStore: SessionStore, templateStore: TemplateStore, isPro: Bool) {
        sessionLog = sessionStore.startSession(templateId: template.id, source: .phone)
        templateStore.markUsed(template)
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        scheduleNotifications()
        startTimer()
        liveActivityEnabled = isPro
        if isPro { startLiveActivity() }
        updateWidgetDefaults()
        HapticService.success()
    }

    func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
        cancelNotifications()
        updateLiveActivity()
        updateWidgetDefaults(running: false)
    }

    func resume() {
        isPaused = false
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        scheduleNotifications()
        startTimer()
        updateLiveActivity()
        updateWidgetDefaults()
    }

    func extend(minutes: Int = 5) {
        extendedCount += 1
        remainingSeconds += minutes * 60
        totalSeconds    += minutes * 60
        endDate = endDate.addingTimeInterval(TimeInterval(minutes * 60))
        cancelNotifications()
        scheduleNotifications()
        updateLiveActivity()

        if isFinished {
            isFinished = false
            startTimer()
            if liveActivityEnabled { startLiveActivity() }
        }
    }

    func stop(sessionStore: SessionStore, completed: Bool) {
        timer?.invalidate()
        timer = nil
        cancelNotifications()
        endLiveActivity()
        updateWidgetDefaults(running: false)

        if let id = sessionLog?.id {
            sessionStore.endSession(id: id, completed: completed)
        }
        isFinished = true
    }

    func saveNote(sessionStore: SessionStore, note: String) {
        guard let id = sessionLog?.id else { return }
        sessionStore.updateNote(id: id, note: note)
    }

    func cleanup() {
        timer?.invalidate()
        timer = nil
        cancelNotifications()
        endLiveActivity()
        updateWidgetDefaults(running: false)
    }

    // MARK: - Display

    var timeString: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var progress: Double {
        let total = Double(totalSeconds)
        guard total > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / total)
    }

    // MARK: - Private Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, !self.isPaused else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.checkAlerts()
                if self.remainingSeconds % 15 == 0 { self.updateLiveActivity() }
            } else {
                self.onTimeUp()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func checkAlerts() {
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
        endLiveActivity()
        updateWidgetDefaults(running: false)
        playEndHaptic()
    }

    private func playHaptic(for offset: Int) {
        if offset >= 300 {
            HapticService.warning()
        } else {
            HapticService.tap(style: template.hapticStyle, count: template.hapticCount)
        }
    }

    private func playEndHaptic() {
        HapticService.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticService.success()
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

    // MARK: - Live Activity

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attrs = ShimedokiActivityAttributes(
            templateTitle: template.title,
            colorHex: template.colorHex,
            totalSeconds: totalSeconds
        )
        let state = ShimedokiActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            isPaused: false,
            isFinished: false
        )
        let content = ActivityContent(state: state, staleDate: endDate.addingTimeInterval(60))
        activity = try? Activity.request(attributes: attrs, content: content)
    }

    private func updateLiveActivity() {
        guard let activity else { return }
        let state = ShimedokiActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            isPaused: isPaused,
            isFinished: isFinished
        )
        let content = ActivityContent(state: state, staleDate: endDate.addingTimeInterval(60))
        Task { await activity.update(content) }
    }

    private func endLiveActivity() {
        guard let activity else { return }
        let state = ShimedokiActivityAttributes.ContentState(
            remainingSeconds: 0,
            isPaused: false,
            isFinished: true
        )
        let content = ActivityContent(state: state, staleDate: nil)
        Task { await activity.end(content, dismissalPolicy: .after(.now + 4)) }
        self.activity = nil
    }

    // MARK: - Widget Defaults

    private func updateWidgetDefaults(running: Bool = true) {
        let defaults = UserDefaults(suiteName: "group.com.mankai.shimedoki")
        defaults?.set(template.title, forKey: "widget.lastTemplateTitle")
        defaults?.set(template.colorHex, forKey: "widget.lastTemplateColor")
        defaults?.set(running, forKey: "widget.sessionRunning")
        defaults?.set(remainingSeconds, forKey: "widget.remainingSeconds")
    }
}
