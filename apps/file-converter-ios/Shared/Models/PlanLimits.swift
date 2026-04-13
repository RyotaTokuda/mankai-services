import Foundation

enum PlanLimits {
    // MARK: - Free

    static let freeMaxFilesPerJob = 5
    static let freeMaxFileSizeMB = 25
    static let freeMaxTotalJobSizeMB = 100

    // MARK: - Plus

    static let plusMaxFilesPerJob = 100
    static let plusMaxFileSizeMB = 500
    static let plusMaxTotalJobSizeMB = 5120

    // MARK: - Queries

    static func maxFilesPerJob(isPlus: Bool) -> Int {
        isPlus ? plusMaxFilesPerJob : freeMaxFilesPerJob
    }

    static func maxFileSizeMB(isPlus: Bool) -> Int {
        isPlus ? plusMaxFileSizeMB : freeMaxFileSizeMB
    }

    static func maxTotalJobSizeMB(isPlus: Bool) -> Int {
        isPlus ? plusMaxTotalJobSizeMB : freeMaxTotalJobSizeMB
    }

    /// 一括処理（6ファイル以上）
    static func canBatchProcess(isPlus: Bool) -> Bool { isPlus }

    /// プリセット保存
    static func canSavePreset(isPlus: Bool) -> Bool { isPlus }

    /// ジョブ履歴
    static func canViewHistory(isPlus: Bool) -> Bool { isPlus }

    /// PDFページ編集（削除・抽出・回転）
    static func canEditPdfPages(isPlus: Bool) -> Bool { isPlus }

    /// メタデータ削除
    static func canRemoveMetadata(isPlus: Bool) -> Bool { isPlus }

    /// PDFパスワード設定
    static func canSetPdfPassword(isPlus: Bool) -> Bool { isPlus }

    /// 高度圧縮（DPI指定・グレースケール）
    static func canAdvancedCompress(isPlus: Bool) -> Bool { isPlus }

    /// 広告非表示
    static func showAds(isPlus: Bool) -> Bool { !isPlus }
}
