import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            TabView {
                TemplateListView()
                    .tabItem {
                        Label(S.Tab.scenes, systemImage: "list.bullet")
                    }
                HistoryView()
                    .tabItem {
                        Label(S.Tab.history, systemImage: "clock.arrow.circlepath")
                    }
                SettingsView()
                    .tabItem {
                        Label(S.Tab.settings, systemImage: "gearshape")
                    }
            }
        } else {
            OnboardingView()
        }
    }
}
