import Foundation

/// 不調記録の1件分
/// 症状・強さ・服薬・環境・Healthデータを全てまとめて保持する
struct SymptomRecord: Codable, Identifiable {
    let id: UUID
    /// 過去日記録に対応するため var にしている
    var createdAt: Date
    var updatedAt: Date

    /// 記録元デバイス
    var sourceDevice: SourceDevice

    // ── 症状 ──────────────────────────────────────────────
    /// デフォルト症状の場合
    var symptomType: SymptomType?
    /// カスタム症状の場合
    var customSymptomId: UUID?
    /// 表示用の症状名（カスタム症状の名前を保存しておく）
    var customSymptomName: String?

    // ── 強さ ──────────────────────────────────────────────
    /// 1〜5 の 5段階
    var severity: Int

    // ── メモ ──────────────────────────────────────────────
    var note: String?

    // ── 服薬 ──────────────────────────────────────────────
    var medicationTaken: Bool
    var medicationTakenAt: Date?
    var customMedicationId: UUID?
    var customMedicationName: String?

    // ── 落ち着いた ────────────────────────────────────────
    var settledAt: Date?

    // ── 環境データ（記録時スナップショット） ──────────────
    var environment: EnvironmentSnapshot?

    // ── Health データ（記録時サマリー） ───────────────────
    var healthSummary: HealthSnapshot?

    // ── タグ（将来拡張用） ───────────────────────────────
    var tags: [String]

    init(
        symptomType: SymptomType? = nil,
        customSymptomId: UUID? = nil,
        customSymptomName: String? = nil,
        severity: Int,
        sourceDevice: SourceDevice,
        note: String? = nil,
        medicationTaken: Bool = false,
        tags: [String] = [],
        date: Date = Date()
    ) {
        self.id = UUID()
        self.createdAt = date
        self.updatedAt = date
        self.sourceDevice = sourceDevice
        self.symptomType = symptomType
        self.customSymptomId = customSymptomId
        self.customSymptomName = customSymptomName
        self.severity = severity
        self.note = note
        self.medicationTaken = medicationTaken
        self.medicationTakenAt = nil
        self.customMedicationId = nil
        self.customMedicationName = nil
        self.settledAt = nil
        self.environment = nil
        self.healthSummary = nil
        self.tags = tags
    }
}
