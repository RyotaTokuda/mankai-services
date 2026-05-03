import SwiftUI
import StoreKit

struct SubscriptionManagementView: View {
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label(S.Subscription.currentPlan, systemImage: "checkmark.seal.fill")
                        Spacer()
                        Text(planService.isPro ? S.Subscription.planPlus : S.Subscription.planFree)
                            .foregroundStyle(planService.isPro ? .green : .secondary)
                    }
                }

                Section {
                    Button(S.Subscription.restorePurchase) {
                        Task { await planService.restorePurchases() }
                    }

                    Link(S.Subscription.openSettings,
                         destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                }

                Section {
                    Text(S.Subscription.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(S.Subscription.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(S.Subscription.close) { dismiss() }
                }
            }
        }
    }
}
