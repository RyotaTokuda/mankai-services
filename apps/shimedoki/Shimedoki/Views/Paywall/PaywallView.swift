import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PaywallViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── ヘッダー ──
                    headerSection

                    // ── 価格訴求バナー ──
                    priceBanner
                        .padding(.top, 20)

                    // ── ベネフィット一覧 ──
                    benefitsSection
                        .padding(.top, 24)

                    // ── プラン選択 ──
                    planPickerSection
                        .padding(.top, 24)

                    // ── CTA ──
                    ctaSection
                        .padding(.top, 20)

                    // ── フッター ──
                    footerSection
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(S.Paywall.close) { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
            .task {
                await viewModel.loadProducts(planService: planService)
                AnalyticsService.log(.paywallViewed)
            }
            .onChange(of: viewModel.purchaseSuccess) { _, success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("⏱")
                .font(.system(size: 52))
                .padding(.top, 28)

            Text("しめどき Plus")
                .font(.title2)
                .fontWeight(.bold)

            Text("会議を、もっとスマートに締める")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Price Banner

    private var priceBanner: some View {
        HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("月額")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("¥200")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                Text("1日約7円")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 50)

            VStack(spacing: 2) {
                Text("年額")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("¥1,500")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                Text("月約125円・37%オフ")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(Color.accentColor.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Plusでできること")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)

            VStack(spacing: 2) {
                BenefitRow(icon: "iphone.and.arrow.forward",
                           color: .blue,
                           text: S.Paywall.benefitLiveActivity,
                           badge: "NEW")
                BenefitRow(icon: "applewatch",
                           color: .indigo,
                           text: S.Paywall.benefitWatchFace,
                           badge: "NEW")
                BenefitRow(icon: "rectangle.stack",
                           color: .teal,
                           text: S.Paywall.benefitWidget,
                           badge: "NEW")
                BenefitRow(icon: "chart.bar.fill",
                           color: .orange,
                           text: S.Paywall.benefitWeeklySummary,
                           badge: "NEW")
                BenefitRow(icon: "square.grid.2x2.fill",
                           color: .purple,
                           text: S.Paywall.benefitCustomIcon,
                           badge: "NEW")
                BenefitRow(icon: "note.text",
                           color: .green,
                           text: S.Paywall.benefitNote,
                           badge: nil)
                Divider().padding(.vertical, 4)
                BenefitRow(icon: "infinity",
                           color: .primary,
                           text: S.Paywall.benefitUnlimitedScenes,
                           badge: nil)
                BenefitRow(icon: "slider.horizontal.3",
                           color: .primary,
                           text: S.Paywall.benefitCustomAlert,
                           badge: nil)
                BenefitRow(icon: "clock.arrow.circlepath",
                           color: .primary,
                           text: S.Paywall.benefitHistory,
                           badge: nil)
                BenefitRow(icon: "calendar",
                           color: .primary,
                           text: S.Paywall.benefitCalendar,
                           badge: nil)
            }
        }
    }

    // MARK: - Plan Picker

    private var planPickerSection: some View {
        VStack(spacing: 10) {
            if let yearly = planService.yearlyProduct {
                PlanButton(
                    title: S.Paywall.labelYearly,
                    price: yearly.displayPrice,
                    subtitle: S.Paywall.yearlyMonthlyEquiv,
                    badge: S.Paywall.badgeRecommended,
                    isSelected: viewModel.selectedProduct?.id == yearly.id
                ) { viewModel.selectedProduct = yearly }
            }
            if let monthly = planService.monthlyProduct {
                PlanButton(
                    title: S.Paywall.labelMonthly,
                    price: monthly.displayPrice,
                    subtitle: S.Paywall.perDayPrice,
                    badge: nil,
                    isSelected: viewModel.selectedProduct?.id == monthly.id
                ) { viewModel.selectedProduct = monthly }
            }
            if planService.products.isEmpty {
                PlanButton(title: "年額", price: "¥1,500", subtitle: "月約125円・37%オフ",
                           badge: "おトク", isSelected: true) {}
                PlanButton(title: "月額", price: "¥200", subtitle: "1日約7円",
                           badge: nil, isSelected: false) {}
            }
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        Group {
            if viewModel.purchaseSuccess {
                Label(S.Paywall.plusStarted, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Button {
                    Task { await viewModel.purchase(planService: planService) }
                } label: {
                    Group {
                        if viewModel.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text(S.Paywall.startPlus)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)

                if let error = viewModel.purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 8) {
            Button(S.Paywall.restorePurchase) {
                Task { await planService.restorePurchases() }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(S.Paywall.legalText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - BenefitRow

private struct BenefitRow: View {
    let icon: String
    let color: Color
    let text: String
    let badge: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color == .primary ? Color.accentColor : color)
                .frame(width: 28)

            Text(text)
                .font(.subheadline)

            if let badge {
                Text(badge)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.vertical, 7)
    }
}

// MARK: - PlanButton

private struct PlanButton: View {
    let title: String
    let price: String
    let subtitle: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if let badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(price)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.07) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
