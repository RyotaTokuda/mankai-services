import SwiftUI

@Observable
final class TemplateListViewModel {
    var showingPaywall = false
    var selectedCategory: TemplateCategory?

    func filteredTemplates(from store: TemplateStore) -> [Template] {
        let sorted = store.sortedTemplates()
        guard let category = selectedCategory else { return sorted }
        return sorted.filter { $0.category == category }
    }

    func canAdd(store: TemplateStore, planService: PlanService) -> Bool {
        planService.canAddTemplate(currentCount: store.templates.count)
    }

    func handleAddTap(store: TemplateStore, planService: PlanService) -> Bool {
        if canAdd(store: store, planService: planService) {
            return true
        } else {
            showingPaywall = true
            return false
        }
    }
}
