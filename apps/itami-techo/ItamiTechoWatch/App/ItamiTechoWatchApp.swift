import SwiftUI

@main
struct ItamiTechoWatchApp: App {
    @State private var recordStore = RecordStore()
    @State private var customSymptomStore = CustomSymptomStore()
    @State private var planService = PlanService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environment(recordStore)
                .environment(customSymptomStore)
                .environment(planService)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        recordStore.reload()
                        customSymptomStore.reload()
                        Task { await planService.checkEntitlements() }
                    }
                }
                .onAppear {
                    setupWatchSync()
                }
        }
    }

    private func setupWatchSync() {
        let sync = WatchSyncService.shared
        sync.activate()

        sync.onRecordReceived = { [recordStore] record in
            recordStore.add(record)
        }
        sync.onRecordUpdated = { [recordStore] record in
            recordStore.update(record)
        }
        sync.onRecordDeleted = { [recordStore] id in
            recordStore.delete(id: id)
        }
    }
}
