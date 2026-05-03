import SwiftUI
import StoreKit

@Observable
final class PaywallViewModel {
    var selectedProduct: Product?
    var isPurchasing = false
    var purchaseError: String?
    var purchaseSuccess = false

    func loadProducts(planService: PlanService) async {
        await planService.loadProducts()
        // デフォルトで年額を選択
        selectedProduct = planService.yearlyProduct ?? planService.monthlyProduct
    }

    func purchase(planService: PlanService) async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        purchaseError = nil
        do {
            let success = try await planService.purchase(product)
            if success {
                purchaseSuccess = true
                AnalyticsService.log(.paywallConverted, parameters: [
                    "product": product.id
                ])
            }
        } catch {
            purchaseError = "購入処理に失敗しました"
        }
        isPurchasing = false
    }

    func yearlyMonthlyCost(_ product: Product) -> String {
        let monthly = product.price / 12
        return monthly.formatted(.currency(code: product.priceFormatStyle.currencyCode ?? "JPY"))
    }
}
