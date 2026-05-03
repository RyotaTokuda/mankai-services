import SwiftUI

@Observable
final class TemplateEditViewModel {
    var title: String
    var durationMinutes: Int
    var category: TemplateCategory
    var alertOffsets: [Int]
    var hapticStyle: HapticStyle
    var colorHex: String
    var isPinned: Bool

    let templateId: UUID
    let isNew: Bool

    static let presetColors: [String] = [
        "#1A6FD4", "#00A060", "#8A3DC0", "#E8A000",
        "#D94020", "#7A7A80", "#00A8B8", "#F07020"
    ]

    static let durationPresets: [Int] = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120]

    /// 固定プリセット（無料版用）
    static let alertPresets: [[Int]] = [
        [300, 60],       // 残り5分 + 残り1分
        [600, 300, 60],  // 残り10分 + 5分 + 1分
        [60],            // 残り1分のみ
        [300],           // 残り5分のみ
    ]

    init(template: Template, isNew: Bool) {
        self.templateId = template.id
        self.isNew = isNew
        self.title = template.title
        self.durationMinutes = template.durationMinutes
        self.category = template.category
        self.alertOffsets = template.alertOffsets
        self.hapticStyle = template.hapticStyle
        self.colorHex = template.colorHex
        self.isPinned = template.isPinned
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && durationMinutes > 0
    }

    func toTemplate(original: Template) -> Template {
        var t = original
        t.title = title.trimmingCharacters(in: .whitespaces)
        t.durationMinutes = durationMinutes
        t.category = category
        t.alertOffsets = alertOffsets
        t.hapticStyle = hapticStyle
        t.colorHex = colorHex
        t.isPinned = isPinned
        return t
    }

    func alertOffsetsDescription() -> String {
        alertOffsets.map { offset in
            if offset >= 60 {
                return "残り\(offset / 60)分"
            } else {
                return "残り\(offset)秒"
            }
        }.joined(separator: " · ")
    }
}
