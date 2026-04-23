import SwiftUI
import StoreKit

/// プラン管理画面
/// 無料ユーザー → アップグレード訴求
/// プレミアムユーザー → 現在のプラン情報 + サブスク管理リンク
struct PlanManagementView: View {
    @Environment(PlanService.self) private var planService
    @State private var showingPaywall = false
    @State private var isRestoring = false

    var body: some View {
        List {
            if planService.isPremium {
                premiumSection
            } else {
                freeSection
            }
        }
        .navigationTitle(S.Settings.subscription)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    // MARK: - プレミアム済み

    private var premiumSection: some View {
        Group {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(S.Settings.planPremium)
                            .font(.headline)
                        Text("すべての機能をご利用いただけます")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("プレミアム機能") {
                FeatureCheckRow(text: "無制限の履歴保存")
                FeatureCheckRow(text: "通院向けPDF / CSVレポート")
                FeatureCheckRow(text: "曜日別・90日間の傾向分析")
                FeatureCheckRow(text: "天気・気圧・Health 高度分析")
                FeatureCheckRow(text: "カスタム症状・薬タグ無制限")
            }

            Section {
                Button(S.Settings.planManageSubscription) {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundStyle(Color.accentColor)
            }
        }
    }

    // MARK: - 無料プラン

    private var freeSection: some View {
        Group {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(S.Settings.planFree)
                            .font(.headline)
                        Text("基本的な記録・履歴機能が使えます")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("プレミアムでできること") {
                FeatureCheckRow(text: "90日間の無制限履歴")
                FeatureCheckRow(text: "通院向けPDF / CSVレポート出力")
                FeatureCheckRow(text: "曜日別傾向・詳細環境分析")
                FeatureCheckRow(text: "Health連携の詳細分析")
                FeatureCheckRow(text: "カスタム症状・薬タグ無制限")
            }

            Section {
                Button {
                    showingPaywall = true
                } label: {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text(S.Settings.planUpgrade)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("7日間無料トライアルあり")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section {
                Button(S.Settings.planRestore) {
                    Task {
                        isRestoring = true
                        await planService.restore()
                        isRestoring = false
                    }
                }
                .foregroundStyle(.secondary)
                .disabled(isRestoring)
            }
        }
    }
}

private struct FeatureCheckRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            Text(text).font(.subheadline)
        }
    }
}

private struct PlanLimitRow: View {
    let text: String
    let isLimited: Bool
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isLimited ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isLimited ? .red.opacity(0.7) : .green)
            Text(text).font(.subheadline)
        }
    }
}
