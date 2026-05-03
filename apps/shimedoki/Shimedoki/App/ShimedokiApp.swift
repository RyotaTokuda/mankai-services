import SwiftUI

@main
struct ShimedokiApp: App {
    let templateStore = TemplateStore()
    let sessionStore = SessionStore()
    let planService = PlanService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(templateStore)
                .environment(sessionStore)
                .environment(planService)
        }
    }
}
