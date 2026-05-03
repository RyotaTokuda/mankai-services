import SwiftUI

@main
struct ShimedokiWatchApp: App {
    let templateStore = TemplateStore()
    let sessionStore = SessionStore()
    let planService = PlanService()

    var body: some Scene {
        WindowGroup {
            WatchTemplateListView()
                .environment(templateStore)
                .environment(sessionStore)
                .environment(planService)
        }
    }
}
