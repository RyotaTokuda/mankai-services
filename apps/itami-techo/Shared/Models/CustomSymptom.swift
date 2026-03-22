import Foundation

/// ユーザーが追加するカスタム症状
/// 無料: 2件まで、プレミアム: 無制限
struct CustomSymptom: Codable, Identifiable {
    let id: UUID
    var name: String
    var emoji: String?
    let createdAt: Date
    /// 使用回数（よく使う順の並び替えに使用）
    var useCount: Int

    init(name: String, emoji: String? = nil) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.createdAt = Date()
        self.useCount = 0
    }
}
