import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PlanKind = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    enum PlanKind { case yearly, monthly }

    private var yearlyPrice: String { planService.yearlyProduct?.displayPrice ?? "¥4,000" }
    private var monthlyPrice: String { planService.monthlyProduct?.displayPrice ?? "¥400" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    features
                    planCards
                    freeNote
                    legalLinks
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom) { ctaButton }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(S.Common.close) { dismiss() }
                }
            }
            .alert("エラー", isPresented: Binding(
                get: { errorMessage != nil || planService.purchaseError != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? planService.purchaseError ?? "")
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
            FeatureRow(icon: "calendar",          text: S.Paywall.featureHistory)
            FeatureRow(icon: "doc.text",          text: S.Paywall.featureReport)
            FeatureRow(icon: "chart.bar",         text: S.Paywall.featureTrends)
            FeatureRow(icon: "cloud.sun",         text: S.Paywall.featureWeather)
            FeatureRow(icon: "barometer",         text: S.Paywall.featurePressure)
            FeatureRow(icon: "heart.text.square", text: S.Paywall.featureHealth)
            FeatureRow(icon: "tag",               text: S.Paywall.featureCustom)
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
                title: S.Paywall.planYearly,
                price: yearlyPrice,
                detail: S.Paywall.yearlyDetail,
                badge: S.Paywall.recommended,
                isSelected: selectedPlan == .yearly
            ) { selectedPlan = .yearly }

            PlanCard(
                kind: .monthly,
                title: S.Paywall.planMonthly,
                price: monthlyPrice,
                detail: S.Paywall.monthlyDetail,
                badge: nil,
                isSelected: selectedPlan == .monthly
            ) { selectedPlan = .monthly }
        }
        .padding(.horizontal, 20)
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
                Link(S.Legal.termsOfService, destination: URL(string: "https://mankai-software.com/terms")!)
                Link(S.Legal.privacyPolicy, destination: URL(string: "https://mankai-software.com/privacy")!)
            }
            .font(.caption2)

            Text(S.Paywall.subscriptionDisclosure)
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
                Text(S.Paywall.ctaStart)
                    .font(.headline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isPurchasing)

            Text(S.Paywall.trialAutoRenew)
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }

    // MARK: - Purchase

    private func purchase() {
        let product = selectedPlan == .yearly ? planService.yearlyProduct : planService.monthlyProduct
        guard let product else {
            errorMessage = "商品情報を読み込み中です。しばらく待ってから再試行してください。"
            return
        }
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
