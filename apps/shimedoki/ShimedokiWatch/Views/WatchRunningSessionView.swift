import SwiftUI

struct WatchRunningSessionView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss
    @Bindable var session: SessionViewModel
    @State private var showingExtend = false
    @State private var showingComplete = false

    var body: some View {
        if session.isFinished && !showingExtend {
            WatchSessionCompleteView(session: session) {
                dismiss()
            }
        } else {
            VStack(spacing: 12) {
                // テンプレ名
                Text(session.template.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // 残り時間（大きく）
                Text(session.timeString)
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(timeColor)

                // プログレス
                ProgressView(value: session.progress)
                    .tint(Color(hex: session.template.colorHex))

                // コントロール
                HStack(spacing: 16) {
                    // 一時停止 / 再開
                    Button {
                        WatchHapticService.tap()
                        if session.isPaused {
                            session.resume()
                        } else {
                            session.pause()
                        }
                    } label: {
                        Image(systemName: session.isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)

                    // 5分延長
                    Button {
                        WatchHapticService.tap()
                        session.extend(minutes: 5)
                        if let id = session.sessionLog?.id {
                            sessionStore.incrementExtension(id: id)
                        }
                        WatchAnalytics.log("template_extended", params: ["minutes": "5"])
                    } label: {
                        Text(S.Watch.extend5)
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)

                    // 終了
                    Button {
                        WatchHapticService.tap()
                        session.stop(sessionStore: sessionStore, completed: false)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding(.horizontal, 4)
            .onDisappear {
                session.cleanup()
            }
        }
    }

    private var timeColor: Color {
        if session.remainingSeconds <= 60 {
            return .red
        } else if session.remainingSeconds <= 300 {
            return .orange
        } else {
            return .primary
        }
    }
}
