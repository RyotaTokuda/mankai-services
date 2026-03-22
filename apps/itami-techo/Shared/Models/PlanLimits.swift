import Foundation

/// 無料 / プレミアムのプラン制限
enum PlanLimits {
    /// 無料プランの制限
    enum Free {
        /// 履歴保持日数
        static let historyDays = 14
        /// カスタム症状の最大数
        static let maxCustomSymptoms = 2
        /// カスタム薬タグ使用可否
        static let canUseCustomMedication = false
        /// PDF/CSV 出力可否
        static let canExport = false
        /// 高度分析（環境・Health）可否
        static let canUseAdvancedAnalysis = false
        /// 通院向け要約可否
        static let canUseMedicalReport = false
        /// 月次レポート可否
        static let canUseMonthlyReport = false
        /// 通知感度調整可否
        static let canCustomizeNotification = false
        /// Siri ショートカット可否
        static let canUseSiriShortcuts = false
        /// 長期比較可否
        static let canUseLongTermComparison = false
    }

    /// プレミアムプランの制限
    enum Premium {
        static let historyDays = Int.max
        static let maxCustomSymptoms = Int.max
        static let canUseCustomMedication = true
        static let canExport = true
        static let canUseAdvancedAnalysis = true
        static let canUseMedicalReport = true
        static let canUseMonthlyReport = true
        static let canCustomizeNotification = true
        static let canUseSiriShortcuts = true
        static let canUseLongTermComparison = true
    }
}
