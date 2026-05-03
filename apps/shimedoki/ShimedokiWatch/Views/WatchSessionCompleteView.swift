import SwiftUI

struct WatchSessionCompleteView: View {
    @Environment(SessionStore.self) private var sessionStore
    let session: SessionViewModel
    let onDismiss: () -> Void

    @State private var showingExtend = false

    var body: some View {
        if showingExtend {
            WatchQuickExtendView(session: session) {
                showingExtend = false
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.green)

                Text(S.Watch.wellDone)
                    .font(.headline)

                Text(session.template.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if session.extendedCount > 0 {
                    Text("\(session.extendedCount)回延長しました")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Button {
                        WatchHapticService.tap()
                        showingExtend = true
                    } label: {
                        Text(S.Watch.extend)
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        WatchHapticService.tap()
                        if let id = session.sessionLog?.id {
                            sessionStore.endSession(id: id, completed: true)
                        }
                        WatchAnalytics.log("template_completed", params: [
                            "template": session.template.title,
                            "extended": "\(session.extendedCount)"
                        ])
                        onDismiss()
                    } label: {
                        Text(S.Watch.end)
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
