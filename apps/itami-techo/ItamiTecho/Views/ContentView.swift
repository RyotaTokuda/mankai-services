import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @State private var selectedTab = 0

    var body: some View {
        if !onboardingCompleted {
            OnboardingView(isCompleted: $onboardingCompleted)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            RecordView()
                .tabItem { Label(S.Record.title, systemImage: "plus.circle.fill") }
                .tag(0)

            HistoryView()
                .tabItem { Label(S.History.title, systemImage: "list.bullet") }
                .tag(1)

            TrendsView()
                .tabItem { Label(S.Trends.title, systemImage: "chart.line.uptrend.xyaxis") }
                .tag(2)

            SettingsView()
                .tabItem { Label(S.Settings.title, systemImage: "gearshape") }
                .tag(3)
        }
        .onOpenURL { url in
            guard url.scheme == "itamitecho" else { return }
            switch url.host {
            case "record":   selectedTab = 0
            case "history":  selectedTab = 1
            case "trends":   selectedTab = 2
            case "settings": selectedTab = 3
            default:         selectedTab = 0
            }
        }
    }
}
