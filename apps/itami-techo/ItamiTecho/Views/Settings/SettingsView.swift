import SwiftUI

/// iPhone: 設定画面
struct SettingsView: View {
    @Environment(PlanService.self) private var planService
    @Environment(RecordStore.self) private var recordStore
    @Environment(CustomSymptomStore.self) private var customSymptomStore

    @State private var showingDeleteAllConfirm = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false

    private let privacyURL = URL(string: "https://mankai-software.vercel.app/privacy")!
    private let termsURL = URL(string: "https://mankai-software.vercel.app/terms")!

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
                            Text(S.Settings.iCloudSyncing)
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(S.Settings.iCloudDisabled)
                                    .font(.subheadline)
                                Text(S.Settings.iCloudHint)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text(S.Settings.backup)
                }

                // ── データ管理 ──
                Section {
                    Button(role: .destructive) {
                        showingDeleteAllConfirm = true
                    } label: {
                        Label(S.Settings.deleteAllData, systemImage: "trash")
                    }
                } header: {
                    Text(S.Settings.dataManagement)
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

                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        Label(S.Settings.privacyPolicy, systemImage: "hand.raised")
                            .foregroundStyle(.primary)
                    }

                    Button {
                        showingTerms = true
                    } label: {
                        Label(S.Settings.termsOfService, systemImage: "doc.plaintext")
                            .foregroundStyle(.primary)
                    }
                }

                // ── バージョン ──
                Section {
                    LabeledContent(S.Common.version) {
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

            }
            .navigationTitle(S.Settings.title)
            .sheet(isPresented: $showingPrivacyPolicy) {
                SafariView(url: privacyURL)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showingTerms) {
                SafariView(url: termsURL)
                    .ignoresSafeArea()
            }
        }
        .confirmationDialog(
            S.Settings.deleteAllDataConfirm,
            isPresented: $showingDeleteAllConfirm,
            titleVisibility: .visible
        ) {
            Button(S.Settings.deleteAllDataButton, role: .destructive) {
                recordStore.deleteAll()
                customSymptomStore.deleteAll()
            }
        }
    }
}
