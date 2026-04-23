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
                        Text(S.Settings.planAllFeatures)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section(S.Settings.premiumFeaturesTitle) {
                FeatureCheckRow(text: S.Settings.planFeatureHistory)
                FeatureCheckRow(text: S.Settings.planFeatureReport)
                FeatureCheckRow(text: S.Settings.planFeatureTrends)
                FeatureCheckRow(text: S.Settings.planFeatureAnalysis)
                FeatureCheckRow(text: S.Settings.planFeatureCustom)
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
                        Text(S.Settings.planFreeFeatures)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section(S.Settings.premiumFeaturesUpgradeTitle) {
                FeatureCheckRow(text: S.Settings.planFeatureHistoryFree)
                FeatureCheckRow(text: S.Settings.planFeatureReportFree)
                FeatureCheckRow(text: S.Settings.planFeatureTrendsFree)
                FeatureCheckRow(text: S.Settings.planFeatureHealthFree)
                FeatureCheckRow(text: S.Settings.planFeatureCustomFree)
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
