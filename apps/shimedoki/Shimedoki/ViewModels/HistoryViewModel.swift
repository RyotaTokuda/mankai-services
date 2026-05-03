import SwiftUI

@Observable
final class HistoryViewModel {
    var showingPaywall = false

    func visibleSessions(sessionStore: SessionStore, planService: PlanService) -> [SessionLog] {
        let startDate = planService.historyStartDate()
        return sessionStore.filteredSessions(since: startDate)
    }

    func isLimited(planService: PlanService) -> Bool {
        !planService.isPro
    }

    func handleUnlockTap() {
        showingPaywall = true
    }
}
