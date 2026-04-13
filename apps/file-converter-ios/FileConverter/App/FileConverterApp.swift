import SwiftUI

@main
struct FileConverterApp: App {
    let planService = PlanService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(planService)
        }
    }
}
