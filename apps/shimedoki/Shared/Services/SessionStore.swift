import Foundation

@Observable
final class SessionStore {
    private(set) var sessions: [SessionLog] = []
    private let fileURL: URL

    init() {
        fileURL = AppConstants.sharedContainerURL
            .appendingPathComponent(AppConstants.sessionsFileName)
        load()
    }

    #if DEBUG
    init(preloaded: [SessionLog]) {
        fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("test-sessions-\(UUID()).json")
        sessions = preloaded
    }
    #endif

    // MARK: - Operations

    func startSession(templateId: UUID, source: SessionSource) -> SessionLog {
        let session = SessionLog(templateId: templateId, source: source)
        sessions.append(session)
        save()
        return session
    }

    func endSession(id: UUID, completed: Bool) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].endedAt = Date()
        sessions[index].completed = completed
        save()
    }

    func incrementExtension(id: UUID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].extendedCount += 1
        save()
    }

    func updateNote(id: UUID, note: String) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].note = note.isEmpty ? nil : note
        save()
    }

    // MARK: - Weekly Stats

    func sessionCount(since date: Date) -> Int {
        sessions.filter { $0.startedAt >= date && $0.completed }.count
    }

    func totalMinutes(since date: Date) -> Int {
        sessions
            .filter { $0.startedAt >= date && $0.completed }
            .compactMap { log -> Int? in
                guard let end = log.endedAt else { return nil }
                return Int(end.timeIntervalSince(log.startedAt) / 60)
            }
            .reduce(0, +)
    }

    /// 期間でフィルタしたセッション（新しい順）
    func filteredSessions(since startDate: Date?) -> [SessionLog] {
        let sorted = sessions.sorted { $0.startedAt > $1.startedAt }
        guard let startDate else { return sorted }
        return sorted.filter { $0.startedAt >= startDate }
    }

    func sessions(for templateId: UUID) -> [SessionLog] {
        sessions.filter { $0.templateId == templateId }
            .sorted { $0.startedAt > $1.startedAt }
    }

    // MARK: - Persistence

    func reload() {
        load()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            sessions = try JSONDecoder.appDecoder.decode([SessionLog].self, from: data)
        } catch { }
    }

    private func save() {
        do {
            let data = try JSONEncoder.appEncoder.encode(sessions)
            try data.write(to: fileURL, options: .atomic)
        } catch { }
    }
}
