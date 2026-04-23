import SwiftUI
import StoreKit

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("hasRequestedReview") private var hasRequestedReview = false
    @Environment(PlanService.self) private var planService
    @Environment(\.requestReview) private var requestReview

    @State private var selectedTab = 0
    @State private var hasSeenTrends = false
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
                .onAppear { hasSeenTrends = true }

            SettingsView()
                .tabItem { Label(S.Settings.title, systemImage: "gearshape") }
                .tag(3)
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            // 傾向タブ(2)から別タブへ切り替えたとき、無料ユーザーにレビューを求める
            if oldTab == 2, newTab != 2,
               hasSeenTrends,
               !planService.isPremium,
               !hasRequestedReview {
                hasRequestedReview = true
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(600))
                    requestReview()
                }
            }
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
