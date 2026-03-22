import Foundation
import Testing
@testable import ItamiTecho

@Suite("SymptomRecord")
struct SymptomRecordTests {

    @Test("デフォルト症状で記録を作成できる")
    func createWithDefaultSymptom() {
        let record = SymptomRecord(
            symptomType: .headache,
            severity: 3,
            sourceDevice: .iPhone
        )
        #expect(record.symptomType == .headache)
        #expect(record.severity == 3)
        #expect(record.sourceDevice == .iPhone)
        #expect(record.medicationTaken == false)
        #expect(record.settledAt == nil)
        #expect(record.environment == nil)
        #expect(record.healthSummary == nil)
        #expect(record.tags.isEmpty)
    }

    @Test("カスタム症状で記録を作成できる")
    func createWithCustomSymptom() {
        let customId = UUID()
        let record = SymptomRecord(
            customSymptomId: customId,
            customSymptomName: "腰痛",
            severity: 4,
            sourceDevice: .watch
        )
        #expect(record.symptomType == nil)
        #expect(record.customSymptomId == customId)
        #expect(record.customSymptomName == "腰痛")
        #expect(record.sourceDevice == .watch)
    }

    @Test("JSON エンコード/デコードの往復")
    func codableRoundTrip() throws {
        let record = SymptomRecord(
            symptomType: .dizziness,
            severity: 2,
            sourceDevice: .watch,
            note: "朝起きた直後",
            medicationTaken: true
        )
        let data = try JSONEncoder.appEncoder.encode(record)
        let decoded = try JSONDecoder.appDecoder.decode(SymptomRecord.self, from: data)
        #expect(decoded.id == record.id)
        #expect(decoded.symptomType == .dizziness)
        #expect(decoded.severity == 2)
        #expect(decoded.note == "朝起きた直後")
        #expect(decoded.medicationTaken == true)
    }

    @Test("環境データ付き記録の JSON 往復")
    func codableWithEnvironment() throws {
        var record = SymptomRecord(symptomType: .headache, severity: 3, sourceDevice: .iPhone)
        record.environment = EnvironmentSnapshot(
            weatherCondition: "曇り",
            pressure: 1008.5,
            pressureTrend3h: -3.2,
            temperature: 22.0,
            humidity: 75.0,
            airQualityIndex: 85,
            pm25: 12.3,
            locationApprox: LocationApprox(latitude: 35.68, longitude: 139.76, city: "千代田区")
        )
        let data = try JSONEncoder.appEncoder.encode(record)
        let decoded = try JSONDecoder.appDecoder.decode(SymptomRecord.self, from: data)
        #expect(decoded.environment?.pressure == 1008.5)
        #expect(decoded.environment?.locationApprox?.city == "千代田区")
    }
}

@Suite("SymptomType")
struct SymptomTypeTests {

    @Test("全6種のデフォルト症状が存在する")
    func allCases() {
        #expect(SymptomType.allCases.count == 6)
    }

    @Test("全症状に表示名がある")
    func allHaveDisplayNames() {
        for type in SymptomType.allCases {
            let name = S.Symptom.name(for: type)
            #expect(!name.isEmpty)
        }
    }
}

@Suite("PlanLimits")
struct PlanLimitsTests {

    @Test("無料プランの履歴日数は14日")
    func freeHistoryDays() {
        #expect(PlanLimits.Free.historyDays == 14)
    }

    @Test("無料プランのカスタム症状は2件まで")
    func freeCustomSymptoms() {
        #expect(PlanLimits.Free.maxCustomSymptoms == 2)
    }

    @Test("プレミアムは無制限")
    func premiumUnlimited() {
        #expect(PlanLimits.Premium.historyDays == Int.max)
        #expect(PlanLimits.Premium.maxCustomSymptoms == Int.max)
        #expect(PlanLimits.Premium.canExport == true)
    }

    @Test("無料プランではエクスポート不可")
    func freeCannotExport() {
        #expect(PlanLimits.Free.canExport == false)
    }
}

@Suite("Severity")
struct SeverityTests {

    @Test("5段階全てにラベルがある")
    func allLevelsHaveLabels() {
        for level in 1...5 {
            let label = S.Severity.label(for: level)
            #expect(!label.isEmpty)
        }
    }
}

@Suite("CustomSymptom")
struct CustomSymptomTests {

    @Test("初期使用回数は0")
    func initialUseCountIsZero() {
        let symptom = CustomSymptom(name: "腰痛")
        #expect(symptom.useCount == 0)
        #expect(symptom.name == "腰痛")
    }
}

@Suite("SymptomRecord+Display")
struct SymptomRecordDisplayTests {

    @Test("デフォルト症状の displayName")
    func defaultSymptomDisplayName() {
        let record = SymptomRecord(symptomType: .headache, severity: 3, sourceDevice: .iPhone)
        #expect(record.displayName == S.Symptom.headache)
    }

    @Test("カスタム症状の displayName")
    func customSymptomDisplayName() {
        let record = SymptomRecord(customSymptomId: UUID(), customSymptomName: "腰痛", severity: 2, sourceDevice: .watch)
        #expect(record.displayName == "腰痛")
    }

    @Test("症状未指定の displayName はカスタム")
    func noSymptomDisplayName() {
        let record = SymptomRecord(severity: 1, sourceDevice: .iPhone)
        #expect(record.displayName == S.Symptom.custom)
    }

    @Test("severityColor が全レベルで返る")
    func severityColorAllLevels() {
        for level in 1...5 {
            let color = SymptomRecord.color(for: level)
            #expect(color != .clear)
        }
    }
}

@Suite("SymptomRecord 過去日記録")
struct PastDateRecordTests {

    @Test("date パラメータで過去日を指定できる")
    func createWithPastDate() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let record = SymptomRecord(symptomType: .fatigue, severity: 2, sourceDevice: .iPhone, date: pastDate)
        #expect(Calendar.current.isDate(record.createdAt, inSameDayAs: pastDate))
        #expect(record.environment == nil)
    }

    @Test("date 省略時は現在時刻")
    func createWithoutDate() {
        let before = Date()
        let record = SymptomRecord(symptomType: .headache, severity: 3, sourceDevice: .iPhone)
        let after = Date()
        #expect(record.createdAt >= before)
        #expect(record.createdAt <= after)
    }
}

@Suite("RecordStore")
struct RecordStoreTests {

    @Test("レコード追加と取得")
    func addAndRetrieve() {
        let store = RecordStore()
        let record = SymptomRecord(symptomType: .headache, severity: 3, sourceDevice: .iPhone)
        store.add(record)
        #expect(store.records.contains(where: { $0.id == record.id }))
    }

    @Test("重複IDは追加されない")
    func duplicateIdRejected() {
        let store = RecordStore()
        let record = SymptomRecord(symptomType: .headache, severity: 3, sourceDevice: .iPhone)
        store.add(record)
        store.add(record)
        #expect(store.records.filter({ $0.id == record.id }).count == 1)
    }

    @Test("レコード削除")
    func deleteRecord() {
        let store = RecordStore()
        let record = SymptomRecord(symptomType: .dizziness, severity: 2, sourceDevice: .watch)
        store.add(record)
        store.delete(id: record.id)
        #expect(!store.records.contains(where: { $0.id == record.id }))
    }

    @Test("服薬記録")
    func markMedication() {
        let store = RecordStore()
        let record = SymptomRecord(symptomType: .headache, severity: 4, sourceDevice: .iPhone)
        store.add(record)
        store.markMedicationTaken(id: record.id)
        let updated = store.records.first { $0.id == record.id }
        #expect(updated?.medicationTaken == true)
        #expect(updated?.medicationTakenAt != nil)
    }

    @Test("落ち着いた記録")
    func markSettled() {
        let store = RecordStore()
        let record = SymptomRecord(symptomType: .nausea, severity: 3, sourceDevice: .watch)
        store.add(record)
        store.markSettled(id: record.id)
        let updated = store.records.first { $0.id == record.id }
        #expect(updated?.settledAt != nil)
    }

    @Test("今日のレコードフィルタ")
    func todayRecords() {
        let store = RecordStore()
        let countBefore = store.todayRecords.count
        let today = SymptomRecord(symptomType: .headache, severity: 2, sourceDevice: .iPhone)
        let yesterday = SymptomRecord(symptomType: .fatigue, severity: 1, sourceDevice: .iPhone, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        store.add(today)
        store.add(yesterday)
        // 今日のレコードは1件増えたはず（昨日の分は含まれない）
        #expect(store.todayRecords.count == countBefore + 1)
        #expect(store.todayRecords.contains(where: { $0.id == today.id }))
        #expect(!store.todayRecords.contains(where: { $0.id == yesterday.id }))
    }
}

@Suite("EnvironmentSnapshot backfill")
struct EnvironmentSnapshotBackfillTests {

    @Test("needsBackfill の JSON 往復")
    func backfillCodable() throws {
        var snapshot = EnvironmentSnapshot()
        snapshot.pressure = 1010.0
        snapshot.needsBackfill = true
        snapshot.backfillDeadline = Date().addingTimeInterval(24 * 3600)

        let data = try JSONEncoder.appEncoder.encode(snapshot)
        let decoded = try JSONDecoder.appDecoder.decode(EnvironmentSnapshot.self, from: data)
        #expect(decoded.needsBackfill == true)
        #expect(decoded.backfillDeadline != nil)
        #expect(decoded.pressure == 1010.0)
    }
}

// Note: ReportCSVGenerator のテストは iOS ターゲットに含まれるため
// テストターゲット（Shared のみ）からはアクセスできない。
// UI テストまたは iOS ターゲット内のテストで検証する。
