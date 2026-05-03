import SwiftUI

struct PhoneRunningSessionView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(TemplateStore.self) private var templateStore
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss
    @Bindable var session: PhoneSessionViewModel
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            if session.isFinished {
                completedView
            } else {
                runningView
            }
        }
        .interactiveDismissDisabled(!session.isFinished)
        .onDisappear {
            session.cleanup()
        }
    }

    // MARK: - Running

    private var runningView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(session.template.title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text(session.timeString)
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timeColor)
                .contentTransition(.numericText())

            ProgressView(value: session.progress)
                .tint(Color(hex: session.template.colorHex))
                .padding(.horizontal, 48)

            Label(S.PhoneSession.watchNote, systemImage: "iphone.radiowaves.left.and.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    Button {
                        if session.isPaused { session.resume() } else { session.pause() }
                    } label: {
                        Label(
                            session.isPaused ? S.PhoneSession.resume : S.PhoneSession.pause,
                            systemImage: session.isPaused ? "play.fill" : "pause.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button {
                        session.extend(minutes: 5)
                    } label: {
                        Label(S.PhoneSession.extend5, systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button(role: .destructive) {
                    session.stop(sessionStore: sessionStore, completed: false)
                } label: {
                    Text(S.PhoneSession.stop)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Completed

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text(S.PhoneSession.wellDone)
                .font(.title2)
                .fontWeight(.semibold)

            Text(session.template.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if session.extendedCount > 0 {
                Text(L("\(session.extendedCount)回延長しました",
                        en: "Extended \(session.extendedCount) time(s)",
                        zhHans: "已延长 \(session.extendedCount) 次",
                        zhHant: "已延長 \(session.extendedCount) 次"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // メモ入力（Plus のみ）
            if planService.canUseSessionNote() {
                VStack(alignment: .leading, spacing: 6) {
                    TextField(S.Paywall.notePlaceholder, text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)

                    if !note.isEmpty {
                        Button(S.Paywall.noteSave) {
                            session.saveNote(sessionStore: sessionStore, note: note)
                        }
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    session.extend(minutes: 5)
                } label: {
                    Label(S.PhoneSession.extend, systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    if let id = session.sessionLog?.id {
                        sessionStore.endSession(id: id, completed: true)
                        if !note.isEmpty {
                            session.saveNote(sessionStore: sessionStore, note: note)
                        }
                    }
                    dismiss()
                } label: {
                    Text(S.Paywall.close)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private var timeColor: Color {
        if session.remainingSeconds <= 60 { return .red }
        else if session.remainingSeconds <= 300 { return .orange }
        else { return .primary }
    }
}
