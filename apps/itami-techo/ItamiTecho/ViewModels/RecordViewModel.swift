import SwiftUI

/// RecordView のビジネスロジック
@Observable
final class RecordViewModel {
    var selectedSymptomType: SymptomType?
    var selectedCustomSymptom: CustomSymptom?
    var severity: Int = 3
    var medicationTaken = false
    var note = ""
    var recordDate = Date()
    var isPastDate = false
    var showingAddCustom = false
    var showingComplete = false
    var lastRecordedRecord: SymptomRecord?

    var hasSelection: Bool {
        selectedSymptomType != nil || selectedCustomSymptom != nil
    }

    /// デフォルト症状をよく使う順に並び替え
    func sortedDefaultSymptoms(from records: [SymptomRecord]) -> [SymptomType] {
        let counts = Dictionary(
            grouping: records.compactMap(\.symptomType),
            by: { $0 }
        ).mapValues(\.count)
        return SymptomType.allCases.sorted { (counts[$0] ?? 0) > (counts[$1] ?? 0) }
    }

    /// 記録を実行
    func performRecord(
        recordStore: RecordStore,
        customSymptomStore: CustomSymptomStore,
        environmentService: EnvironmentService,
        healthService: HealthService
    ) {
        let record = SymptomRecord(
            symptomType: selectedSymptomType,
            customSymptomId: selectedCustomSymptom?.id,
            customSymptomName: selectedCustomSymptom?.name,
            severity: severity,
            sourceDevice: .iPhone,
            note: note.isEmpty ? nil : note,
            medicationTaken: medicationTaken,
            date: isPastDate ? recordDate : Date()
        )

        recordStore.add(record)

        if let customId = selectedCustomSymptom?.id {
            customSymptomStore.incrementUseCount(id: customId)
        }

        WatchSyncService.shared.sendRecord(record)

        // 環境データ + Health データを非同期で取得して後付け（過去日は除く）
        if !isPastDate {
            let recordId = record.id
            Task {
                async let envSnapshot = environmentService.createSnapshot()
                async let healthSnapshot = healthService.createSnapshot()

                let env = await envSnapshot
                recordStore.attachEnvironment(id: recordId, snapshot: env)

                let health = await healthSnapshot
                if health.sleepDurationHours != nil || health.avgHeartRate != nil || health.stepCount != nil {
                    recordStore.attachHealth(id: recordId, snapshot: health)
                }

                if let updated = recordStore.records.first(where: { $0.id == recordId }) {
                    WatchSyncService.shared.sendRecordUpdate(updated)
                }
            }
        }

        lastRecordedRecord = record
        showingComplete = true
        reset()
    }

    private func reset() {
        selectedSymptomType = nil
        selectedCustomSymptom = nil
        severity = 3
        medicationTaken = false
        note = ""
        isPastDate = false
        recordDate = Date()
    }
}
