import Foundation

struct Template: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var durationMinutes: Int
    var category: TemplateCategory
    /// 終了何秒前に通知するか（例: [300, 60] = 残り5分, 残り1分）
    var alertOffsets: [Int]
    var hapticStyle: HapticStyle
    var colorHex: String
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
    /// 最後に使用した日時（最近使ったテンプレの並び替え用）
    var lastUsedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        durationMinutes: Int,
        category: TemplateCategory,
        alertOffsets: [Int] = [300, 60],
        hapticStyle: HapticStyle = .normal,
        colorHex: String = "#1A6FD4",
        isPinned: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.category = category
        self.alertOffsets = alertOffsets
        self.hapticStyle = hapticStyle
        self.colorHex = colorHex
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastUsedAt = lastUsedAt
    }
}
