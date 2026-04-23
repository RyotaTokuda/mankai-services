import SwiftUI
import UserNotifications

/// 通知設定画面
struct NotificationSettingsView: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(PlanService.self) private var planService

    @State private var showingPaywall = false
    @State private var systemAuthStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        List {
            // ── システム権限ステータス ──
            Section {
                switch systemAuthStatus {
                case .authorized:
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text(S.Settings.notificationAuthorized)
                    }
                case .denied:
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                            Text(S.Settings.notificationPermissionDenied)
                                .font(.subheadline)
                        }
                        Button(S.Settings.notificationOpenSettings) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.subheadline)
                    }
                default:
                    Button(S.Settings.notificationAllow) {
                        Task {
                            _ = await notificationService.requestAuthorization()
                            await refreshAuthStatus()
                        }
                    }
                }
            }

            // ── 通知オン/オフ ──
            if systemAuthStatus == .authorized {
                Section {
                    @Bindable var ns = notificationService
                    Toggle(S.Settings.notificationEnabled, isOn: $ns.isEnabled)
                } footer: {
                    Text(S.Settings.notificationFooter)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(S.Settings.notification)
        .navigationBarTitleDisplayMode(.inline)
        .task { await refreshAuthStatus() }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    private func refreshAuthStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        systemAuthStatus = settings.authorizationStatus
    }
}
