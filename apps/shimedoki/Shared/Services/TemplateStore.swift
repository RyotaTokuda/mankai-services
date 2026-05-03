import Foundation

@Observable
final class TemplateStore {
    private(set) var templates: [Template] = []
    private let fileURL: URL

    init() {
        fileURL = AppConstants.sharedContainerURL
            .appendingPathComponent(AppConstants.templatesFileName)
        load()
        if templates.isEmpty {
            templates = DefaultTemplates.create()
            save()
        }
    }

    // MARK: - CRUD

    func add(_ template: Template) {
        templates.append(template)
        save()
    }

    func update(_ template: Template) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        var updated = template
        updated.updatedAt = Date()
        templates[index] = updated
        save()
    }

    func delete(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        let sorted = sortedTemplates()
        let idsToDelete = offsets.map { sorted[$0].id }
        templates.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    func markUsed(_ template: Template) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index].lastUsedAt = Date()
        save()
    }

    /// ピン留め → 最近使った順 → 作成順
    func sortedTemplates() -> [Template] {
        templates.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            if let lDate = lhs.lastUsedAt, let rDate = rhs.lastUsedAt {
                return lDate > rDate
            }
            if lhs.lastUsedAt != nil { return true }
            if rhs.lastUsedAt != nil { return false }
            return lhs.createdAt < rhs.createdAt
        }
    }

    func template(for id: UUID) -> Template? {
        templates.first { $0.id == id }
    }

    // MARK: - Persistence

    func reload() {
        load()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            templates = try JSONDecoder.appDecoder.decode([Template].self, from: data)
        } catch {
            _ = error
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder.appEncoder.encode(templates)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            _ = error
        }
    }
}

// MARK: - JSON Coding Helpers

extension JSONEncoder {
    static let appEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

extension JSONDecoder {
    static let appDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
