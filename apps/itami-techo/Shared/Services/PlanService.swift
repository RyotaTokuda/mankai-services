import Foundation
import StoreKit

/// StoreKit 2 によるプレミアム課金管理
/// Watch と iPhone 両方で利用する
@Observable
final class PlanService {
    private(set) var isPremium = false
    private(set) var products: [Product] = []
    private(set) var purchaseError: String?

    /// 月額プロダクト
    var monthlyProduct: Product? {
        products.first { $0.id == AppConstants.monthlyProductID }
    }

    /// 年額プロダクト
    var yearlyProduct: Product? {
        products.first { $0.id == AppConstants.yearlyProductID }
    }

    private var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransaction(result)
            }
        }
        Task {
            await loadProducts()
            await checkEntitlements()
        }
    }

    deinit {
        updateTask?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: [
                AppConstants.monthlyProductID,
                AppConstants.yearlyProductID,
            ])
        } catch {
            print("[PlanService] loadProducts error: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        do {
            purchaseError = nil
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkEntitlements()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    // MARK: - Restore

    func restore() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }

    // MARK: - Entitlements

    func checkEntitlements() async {
        var hasPremium = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == AppConstants.monthlyProductID ||
                   transaction.productID == AppConstants.yearlyProductID {
                    hasPremium = true
                }
            }
        }
        isPremium = hasPremium
    }

    // MARK: - Helpers

    /// プラン制限に基づく判定ヘルパー
    var historyDays: Int {
        isPremium ? PlanLimits.Premium.historyDays : PlanLimits.Free.historyDays
    }

    var maxCustomSymptoms: Int {
        isPremium ? PlanLimits.Premium.maxCustomSymptoms : PlanLimits.Free.maxCustomSymptoms
    }

    var canExport: Bool {
        isPremium ? PlanLimits.Premium.canExport : PlanLimits.Free.canExport
    }

    var canUseAdvancedAnalysis: Bool {
        isPremium ? PlanLimits.Premium.canUseAdvancedAnalysis : PlanLimits.Free.canUseAdvancedAnalysis
    }

    var canUseMedicalReport: Bool {
        isPremium ? PlanLimits.Premium.canUseMedicalReport : PlanLimits.Free.canUseMedicalReport
    }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.unverified
        }
    }

    private func handleTransaction(_ result: VerificationResult<Transaction>) async {
        guard let transaction = try? checkVerified(result) else { return }
        await transaction.finish()
        await checkEntitlements()
    }

    enum StoreError: Error {
        case unverified
    }
}
