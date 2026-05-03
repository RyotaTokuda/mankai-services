import SwiftUI

struct HistoryView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(TemplateStore.self) private var templateStore
    @Environment(PlanService.self) private var planService
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            List {
                let sessions = viewModel.visibleSessions(
                    sessionStore: sessionStore,
                    planService: planService
                )

                if sessions.isEmpty {
                    ContentUnavailableView(
                        "まだ履歴がありません",
                        systemImage: "clock",
                        description: Text(S.History.emptyDesc)
                    )
                } else {
                    ForEach(sessions) { session in
                        SessionRow(
                            session: session,
                            template: templateStore.template(for: session.templateId)
                        )
                    }
                }

                // 無料ユーザーへのアップグレード導線
                if viewModel.isLimited(planService: planService) {
                    Section {
                        Button {
                            AnalyticsService.log(.historyUnlockTapped)
                            viewModel.handleUnlockTap()
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text(S.History.showAll)
                                Spacer()
                                Text(S.Settings.plus)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .navigationTitle(S.History.navTitle)
            .sheet(isPresented: $viewModel.showingPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - SessionRow

private struct SessionRow: View {
    let session: SessionLog
    let template: Template?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: template?.colorHex ?? "#7A7A80"))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(template?.title ?? S.History.deletedScene)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))

                    if session.completed {
                        Text(S.History.completed)
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else if session.endedAt != nil {
                        Text(S.History.interrupted)
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    } else {
                        Text(S.History.inProgress)
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }

                    if session.extendedCount > 0 {
                        Text("+\(session.extendedCount)回延長")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            sourceIcon
        }
        .padding(.vertical, 2)
    }

    private var sourceIcon: some View {
        Group {
            switch session.source {
            case .watch:    Image(systemName: "applewatch")
            case .phone:    Image(systemName: "iphone")
            case .shortcut: Image(systemName: "command")
            case .calendar: Image(systemName: "calendar")
            }
        }
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
}
