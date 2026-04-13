import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WorkspaceView()
                .tabItem {
                    Label("変換", systemImage: "arrow.triangle.2.circlepath")
                }
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}
