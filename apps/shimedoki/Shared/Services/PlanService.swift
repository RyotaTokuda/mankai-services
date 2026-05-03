import Foundation
import StoreKit

@Observable
final class PlanService {
    private(set) var isPro: Bool = false
    private(set) var products: [Product] = []
    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task { await updatePurchaseStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: AppConstants.allProductIDs)
                .sorted { $0.price < $1.price }
        } catch {
            _ = error
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == AppConstants.plusMonthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == AppConstants.plusYearlyID }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchaseStatus()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }

    // MARK: - Status

    func updatePurchaseStatus() async {
        var hasActive = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if AppConstants.allProductIDs.contains(transaction.productID) {
                    hasActive = true
                    break
                }
            }
        }
        isPro = hasActive
    }

    // MARK: - Limits

    func templateLimit() -> Int {
        PlanLimits.templateLimit(isPro: isPro)
    }

    func canAddTemplate(currentCount: Int) -> Bool {
        currentCount < templateLimit()
    }

    func historyStartDate() -> Date? {
        PlanLimits.historyStartDate(isPro: isPro)
    }

    func canCustomizeAlertOffsets() -> Bool {
        PlanLimits.canCustomizeAlertOffsets(isPro: isPro)
    }

    func canConnectCalendar() -> Bool {
        PlanLimits.canConnectCalendar(isPro: isPro)
    }

    func canUseLiveActivity() -> Bool {
        PlanLimits.canUseLiveActivity(isPro: isPro)
    }

    func canUseCustomIcon() -> Bool {
        PlanLimits.canUseCustomIcon(isPro: isPro)
    }

    func canUseWidget() -> Bool {
        PlanLimits.canUseWidget(isPro: isPro)
    }

    func canUseWeeklySummary() -> Bool {
        PlanLimits.canUseWeeklySummary(isPro: isPro)
    }

    func canUseSessionNote() -> Bool {
        PlanLimits.canUseSessionNote(isPro: isPro)
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await transaction.finish()
                    await self?.updatePurchaseStatus()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    enum StoreError: Error {
        case verificationFailed
    }

}
