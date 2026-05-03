import Foundation

enum SessionSource: String, Codable {
    case watch    = "watch"
    case phone    = "phone"
    case shortcut = "shortcut"
    case calendar = "calendar"
}

struct SessionLog: Codable, Identifiable, Equatable {
    var id: UUID
    var templateId: UUID
    var startedAt: Date
    var endedAt: Date?
    var extendedCount: Int
    var completed: Bool
    var source: SessionSource
    var note: String?

    init(
        id: UUID = UUID(),
        templateId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        extendedCount: Int = 0,
        completed: Bool = false,
        source: SessionSource = .phone,
        note: String? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.extendedCount = extendedCount
        self.completed = completed
        self.source = source
        self.note = note
    }
}
