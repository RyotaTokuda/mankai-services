import SwiftUI

/// iPhone: 設定画面
struct SettingsView: View {
    @Environment(PlanService.self) private var planService

    var body: some View {
        NavigationStack {
            List {
                // ── プラン ──
                Section {
                    NavigationLink {
                        PlanManagementView()
                    } label: {
                        HStack {
                            Label(S.Settings.subscription, systemImage: "crown")
                            Spacer()
                            Text(planService.isPremium ? "Premium" : "Free")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // ── 通知 ──
                Section {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label(S.Settings.notification, systemImage: "bell")
                    }
                }

                // ── Health 連携 ──
                Section {
                    NavigationLink {
                        HealthSettingsView()
                    } label: {
                        Label(S.Settings.healthIntegration, systemImage: "heart.text.square")
                    }
                }

                // ── このアプリについて ──
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label(S.Settings.about, systemImage: "info.circle")
                    }

                    NavigationLink {
                        LegalView()
                    } label: {
                        Label(S.Settings.legal, systemImage: "doc.text")
                    }
                }

                // ── バージョン ──
                Section {
                    LabeledContent("バージョン") {
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(S.Settings.title)
        }
    }
}
