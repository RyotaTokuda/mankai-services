import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PaywallViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.accentColor)

                        Text("もっと便利に変換する")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("大きなファイルも、大量のファイルも。\nPlus で制限なく使えます。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    // Benefits
                    VStack(spacing: 14) {
                        BenefitRow(icon: "doc.on.doc.fill", text: "100ファイルまで一括変換")
                        BenefitRow(icon: "arrow.up.circle.fill", text: "500MBまでの大容量ファイル対応")
                        BenefitRow(icon: "eye.slash.fill", text: "メタデータ削除")
                        BenefitRow(icon: "lock.doc.fill", text: "PDFパスワード設定")
                        BenefitRow(icon: "sparkles", text: "広告なし")
                    }
                    .padding(.horizontal)

                    // Plan selection
                    if !planService.products.isEmpty {
                        VStack(spacing: 12) {
                            if let yearly = planService.yearlyProduct {
                                PlanButton(
                                    product: yearly,
                                    label: "年額",
                                    badge: "おトク",
                                    isSelected: viewModel.selectedProduct?.id == yearly.id
                                ) {
                                    viewModel.selectedProduct = yearly
                                }
                            }
                            if let monthly = planService.monthlyProduct {
                                PlanButton(
                                    product: monthly,
                                    label: "月額",
                                    badge: nil,
                                    isSelected: viewModel.selectedProduct?.id == monthly.id
                                ) {
                                    viewModel.selectedProduct = monthly
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // CTA
                    if viewModel.purchaseSuccess {
                        Label("Plus を開始しました", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.headline)
                    } else {
                        Button {
                            Task { await viewModel.purchase(planService: planService) }
                        } label: {
                            Group {
                                if viewModel.isPurchasing {
                                    ProgressView()
                                } else {
                                    Text("Plus をはじめる")
                                }
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)
                        .padding(.horizontal, 32)
                    }

                    if let error = viewModel.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    // Footer
                    VStack(spacing: 8) {
                        Button("購入を復元") {
                            Task { await planService.restorePurchases() }
                        }
                        .font(.caption)

                        Text("サブスクリプションは自動更新されます。いつでもキャンセルできます。")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Link("利用規約", destination: AppConstants.termsOfServiceURL)
                            Link("プライバシーポリシー", destination: AppConstants.privacyPolicyURL)
                        }
                        .font(.caption2)
                    }
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .task {
                await viewModel.loadProducts(planService: planService)
            }
            .onChange(of: viewModel.purchaseSuccess) { _, success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - BenefitRow

private struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - PlanButton

private struct PlanButton: View {
    let product: Product
    let label: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(label)
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
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.appSeparator, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
