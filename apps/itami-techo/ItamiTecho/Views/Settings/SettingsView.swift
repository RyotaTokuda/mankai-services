import SwiftUI

/// iPhone: 設定画面
struct SettingsView: View {
    @Environment(PlanService.self) private var planService
    @Environment(RecordStore.self) private var recordStore

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

                // ── iCloud 同期 ──
                Section {
                    if FileManager.default.ubiquityIdentityToken != nil {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text("iCloud と同期中")
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("iCloud が無効です")
                                    .font(.subheadline)
                                Text("設定 › Apple Account › iCloud でオンにすると機種変後もデータを引き継げます")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("機種変・バックアップ")
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

                #if DEBUG
                Section("Debug") {
                    Button("シードデータを生成（90日分）") {
                        recordStore.seedDebugData()
                    }
                    .foregroundStyle(.orange)

                    Button(planService.isPremium ? "プレミアムを解除（Debug）" : "プレミアムを有効化（Debug）") {
                        planService.debugTogglePremium()
                    }
                    .foregroundStyle(planService.isPremium ? .red : .blue)
                }
                #endif
            }
            .navigationTitle(S.Settings.title)
        }
    }
}
