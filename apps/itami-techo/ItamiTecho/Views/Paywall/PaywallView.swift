import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PlanKind = .yearly
    @State private var isPurchasing = false

    enum PlanKind { case yearly, monthly }

    private var yearlyPrice: String { planService.yearlyProduct?.displayPrice ?? "¥3,600" }
    private var monthlyPrice: String { planService.monthlyProduct?.displayPrice ?? "¥480" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    features
                    planCards
                    trialTimeline
                    freeNote
                    legalLinks
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom) { ctaButton }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - ヘッダー

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            Text(S.Paywall.title)
                .font(.title2).fontWeight(.bold)
            Text(S.Paywall.subtitle)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - 機能一覧

    private var features: some View {
        VStack(alignment: .leading, spacing: 10) {
            FeatureRow(icon: "calendar",          text: "90日間の無制限履歴")
            FeatureRow(icon: "doc.text",          text: "通院向けPDF / CSVレポート")
            FeatureRow(icon: "cloud.sun",         text: "天気・気圧・空気質の詳細分析")
            FeatureRow(icon: "heart.text.square", text: "Health連携の詳細分析")
            FeatureRow(icon: "chart.bar",         text: "曜日別・強さ分布の傾向分析")
            FeatureRow(icon: "tag",               text: "カスタム症状・薬タグ無制限")
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }

    // MARK: - プランカード

    private var planCards: some View {
        HStack(spacing: 12) {
            PlanCard(
                kind: .yearly,
                title: "年額",
                price: yearlyPrice,
                detail: "月換算 ¥300",
                badge: "おすすめ",
                isSelected: selectedPlan == .yearly
            ) { selectedPlan = .yearly }

            PlanCard(
                kind: .monthly,
                title: "月額",
                price: monthlyPrice,
                detail: "いつでも解約可",
                badge: nil,
                isSelected: selectedPlan == .monthly
            ) { selectedPlan = .monthly }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - トライアルタイムライン

    private var trialTimeline: some View {
        VStack(spacing: 6) {
            Text("どちらのプランも7日間の無料トライアル付き")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                TimelineNode(dayLabel: "今日", desc: "全機能が使えます", isFilled: true)
                TimelineLine()
                TimelineNode(
                    dayLabel: "7日後",
                    desc: selectedPlan == .yearly ? yearlyPrice + "/年" : monthlyPrice + "/月",
                    isFilled: false
                )
            }
            .padding(.horizontal, 60)
        }
    }

    // MARK: - 無料メモ・法的リンク

    private var freeNote: some View {
        VStack(spacing: 8) {
            Text(S.Paywall.freeNote)
                .font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    isPurchasing = true
                    await planService.restore()
                    isPurchasing = false
                    if planService.isPremium { dismiss() }
                }
            } label: {
                Text(S.Paywall.restoreLabel).font(.caption).foregroundStyle(.secondary)
            }
            .disabled(isPurchasing)
        }
        .padding(.horizontal, 24)
    }

    private var legalLinks: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                Link("利用規約", destination: URL(string: "https://mankai-software.com/terms")!)
                Link("プライバシーポリシー", destination: URL(string: "https://mankai-software.com/privacy")!)
            }
            .font(.caption2)

            Text("サブスクリプションは確認時にApple IDに課金されます。現在の期間終了の少なくとも24時間前にキャンセルしない限り自動更新されます。")
                .font(.caption2).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - 固定CTA

    private var ctaButton: some View {
        VStack(spacing: 4) {
            Button {
                purchase()
            } label: {
                Text("7日間無料で始める")
                    .font(.headline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isPurchasing)

            Text("無料期間終了後に自動更新。いつでもキャンセル可。")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }

    // MARK: - Purchase

    private func purchase() {
        let product = selectedPlan == .yearly ? planService.yearlyProduct : planService.monthlyProduct
        guard let product else { return }
        Task {
            isPurchasing = true
            let success = await planService.purchase(product)
            isPurchasing = false
            if success { dismiss() }
        }
    }
}

// MARK: - PlanCard

private struct PlanCard: View {
    let kind: PaywallView.PlanKind
    let title: String
    let price: String
    let detail: String
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline).fontWeight(.semibold)
                    Text(price)
                        .font(.title3).fontWeight(.bold)
                    Text(detail)
                        .font(.caption2).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(.vertical, 12)
                .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                )

                if let badge {
                    Text(badge)
                        .font(.caption2).fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .offset(x: -8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - TimelineNode / Line

private struct TimelineNode: View {
    let dayLabel: String
    let desc: String
    let isFilled: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isFilled ? Color.accentColor : Color(.systemGray5))
                    .frame(width: 10, height: 10)
                if !isFilled {
                    Circle().stroke(Color.accentColor, lineWidth: 1.5)
                        .frame(width: 10, height: 10)
                }
            }
            Text(dayLabel).font(.caption2).fontWeight(.semibold)
            Text(desc).font(.caption2).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TimelineLine: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(height: 1)
            .padding(.bottom, 36)
    }
}

// MARK: - FeatureRow

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body).foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text).font(.subheadline)
        }
    }
}
