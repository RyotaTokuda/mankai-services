import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some View {
        if !onboardingCompleted {
            OnboardingView(isCompleted: $onboardingCompleted)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label(S.Record.title, systemImage: "plus.circle.fill")
                }

            HistoryView()
                .tabItem {
                    Label(S.History.title, systemImage: "list.bullet")
                }

            TrendsView()
                .tabItem {
                    Label(S.Trends.title, systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label(S.Settings.title, systemImage: "gearshape")
                }
        }
    }

}
