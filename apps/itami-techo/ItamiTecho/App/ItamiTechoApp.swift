import SwiftUI

@main
struct ItamiTechoApp: App {
    @State private var recordStore = RecordStore()
    @State private var customSymptomStore = CustomSymptomStore()
    @State private var planService = PlanService()
    @State private var environmentService = EnvironmentService()
    @State private var healthService = HealthService()
    @State private var notificationService = NotificationService()
    private let cloudSync = CloudSyncService()
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
                    switch newPhase {
                    case .active:
                        recordStore.reload()
                        customSymptomStore.reload()
                        Task {
                            await planService.checkEntitlements()
                            await environmentService.processBackfills(store: recordStore)
                            await evaluateNotification()
                            await syncFromCloud()
                        }
                    case .background:
                        Task { await pushToCloud() }
                    default:
                        break
                    }
                }
                .onAppear {
                    setupWatchSync()
                    Task { await cloudSync.setup() }
                }
        }
    }

    // MARK: - iCloud 同期

    private func syncFromCloud() async {
        // pull & merge
        if let cloudRecords = await cloudSync.pullRecords() {
            recordStore.mergeFromCloud(cloudRecords)
        }
        if let cloudSymptoms = await cloudSync.pullSymptoms() {
            customSymptomStore.mergeFromCloud(cloudSymptoms)
        }
        // マージ後に最新状態を push
        await pushToCloud()
    }

    private func pushToCloud() async {
        await cloudSync.push(
            records: recordStore.records,
            symptoms: customSymptomStore.symptoms
        )
    }

    // MARK: - 通知評価

    private func evaluateNotification() async {
        guard notificationService.isEnabled else { return }
        let forecast = await environmentService.fetchPressureForecast()
        await notificationService.evaluateAndNotify(forecast: forecast)
    }

    // MARK: - Watch 同期

    private func setupWatchSync() {
        let sync = WatchSyncService.shared
        sync.activate()

        // WatchSyncService.shared はシングルトンなのでクロージャを保持し続ける。
        // recordStore は @Observable クラスなので weak 参照で循環を防ぐ。
        sync.onRecordReceived = { [weak recordStore] record in
            recordStore?.add(record)
        }
        sync.onRecordUpdated = { [weak recordStore] record in
            recordStore?.update(record)
        }
        sync.onRecordDeleted = { [weak recordStore] id in
            recordStore?.delete(id: id)
        }
    }
}
