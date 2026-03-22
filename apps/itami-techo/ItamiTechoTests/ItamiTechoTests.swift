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
