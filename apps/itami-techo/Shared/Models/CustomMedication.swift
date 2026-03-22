import Foundation

/// ユーザーが追加するカスタム薬タグ
/// プレミアム機能
struct CustomMedication: Codable, Identifiable {
    let id: UUID
    var name: String
    let createdAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
