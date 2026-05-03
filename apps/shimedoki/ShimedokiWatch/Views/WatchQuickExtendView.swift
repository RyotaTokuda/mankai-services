import SwiftUI

struct WatchQuickExtendView: View {
    @Environment(SessionStore.self) private var sessionStore
    let session: SessionViewModel
    let onDismiss: () -> Void

    private let options = [1, 3, 5, 10]

    var body: some View {
        VStack(spacing: 8) {
            Text(S.Watch.extend)
                .font(.headline)
                .padding(.top, 8)

            ForEach(options, id: \.self) { minutes in
                Button {
                    WatchHapticService.tap()
                    session.extend(minutes: minutes)
                    if let id = session.sessionLog?.id {
                        sessionStore.incrementExtension(id: id)
                    }
                    onDismiss()
                } label: {
                    Text(S.Watch.extendMin(minutes))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
