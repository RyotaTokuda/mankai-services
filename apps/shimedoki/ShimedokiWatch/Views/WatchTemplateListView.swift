import SwiftUI

struct WatchTemplateListView: View {
    @Environment(TemplateStore.self) private var store
    @Environment(SessionStore.self) private var sessionStore
    @Environment(PlanService.self) private var planService
    @State private var activeSession: SessionViewModel?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.sortedTemplates()) { template in
                    Button {
                        startSession(template: template)
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(hex: template.colorHex))
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(template.title)
                                    .font(.body)
                                    .lineLimit(1)
                                Text(S.Scene.minutes(template.durationMinutes))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(S.Watch.appTitle)
            .fullScreenCover(item: $activeSession) { session in
                WatchRunningSessionView(session: session)
            }
        }
        .onAppear {
            store.reload()
        }
    }

    private func startSession(template: Template) {
        WatchHapticService.tap()
        let session = SessionViewModel(template: template)
        session.start(sessionStore: sessionStore, templateStore: store)
        activeSession = session
        WatchAnalytics.log("template_started", params: ["template": template.title])
    }
}

// MARK: - SessionViewModel + Identifiable

extension SessionViewModel: Identifiable {
    var id: UUID { sessionLog?.id ?? UUID() }
}

