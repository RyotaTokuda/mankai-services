import SwiftUI
import StoreKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SettingsView: View {
    @Environment(PlanService.self) private var planService
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Plan section
                Section {
                    HStack {
                        Label(
                            planService.isPlus ? "Plus プラン" : "Free プラン",
                            systemImage: planService.isPlus ? "star.fill" : "star"
                        )
                        .foregroundStyle(planService.isPlus ? .orange : .primary)

                        Spacer()

                        if !planService.isPlus {
                            Button("アップグレード") {
                                showPaywall = true
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }

                    if planService.isPlus {
                        Button("サブスクリプションを管理") {
                            #if os(iOS)
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                            #elseif os(macOS)
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                NSWorkspace.shared.open(url)
                            }
                            #endif
                        }
                    }

                    Button("購入を復元") {
                        Task { await planService.restorePurchases() }
                    }
                } header: {
                    Text("プラン")
                }

                // About section
                Section {
                    LabeledContent("バージョン") {
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    }

                    Link(destination: AppConstants.supportURL) {
                        Label("お問い合わせ", systemImage: "envelope")
                    }

                    Link(destination: AppConstants.privacyPolicyURL) {
                        Label("プライバシーポリシー", systemImage: "hand.raised")
                    }

                    Link(destination: AppConstants.termsOfServiceURL) {
                        Label("利用規約", systemImage: "doc.text")
                    }
                } header: {
                    Text("情報")
                }

                // Privacy note
                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("すべての変換は端末内で処理されます")
                                .font(.subheadline)
                            Text("ファイルがサーバーに送信されることはありません")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.green)
                    }
                }

                #if DEBUG
                Section("Debug") {
                    Button("Toggle Plus") {
                        planService.togglePlus()
                    }
                }
                #endif
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}
