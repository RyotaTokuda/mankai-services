import SwiftUI

@main
struct ItamiTechoApp: App {
    @State private var recordStore = RecordStore()
    @State private var customSymptomStore = CustomSymptomStore()
    @State private var planService = PlanService()
    @State private var environmentService = EnvironmentService()
    @State private var healthService = HealthService()
    @State private var notificationService = NotificationService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recordStore)
                .environment(customSymptomStore)
                .environment(planService)
                .environment(environmentService)
                .environment(healthService)
                .environment(notificationService)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        recordStore.reload()
                        customSymptomStore.reload()
                        Task {
                            await planService.checkEntitlements()
                            await environmentService.processBackfills(store: recordStore)
                            await evaluateNotification()
                        }
                    }
                }
                .onAppear {
                    setupWatchSync()
                }
        }
    }

    private func evaluateNotification() async {
        guard notificationService.isEnabled else { return }
        let forecast = await environmentService.fetchPressureForecast()
        await notificationService.evaluateAndNotify(forecast: forecast)
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
