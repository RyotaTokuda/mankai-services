import Foundation

/// カスタム症状の永続化ストア
@Observable
final class CustomSymptomStore {
    private(set) var symptoms: [CustomSymptom] = []
    private let fileURL: URL
    private let coordinator = NSFileCoordinator()

    init() {
        self.fileURL = AppConstants.sharedContainerURL
            .appendingPathComponent(AppConstants.customSymptomsFileName)
        load()
    }

    // MARK: - CRUD

    func add(_ symptom: CustomSymptom) {
        symptoms.append(symptom)
        save()
    }

    func delete(id: UUID) {
        symptoms.removeAll { $0.id == id }
        save()
    }

    func incrementUseCount(id: UUID) {
        guard let index = symptoms.firstIndex(where: { $0.id == id }) else { return }
        symptoms[index].useCount += 1
        save()
    }

    // MARK: - クエリ

    /// 使用頻度順にソート済み
    var sortedByUseCount: [CustomSymptom] {
        symptoms.sorted { $0.useCount > $1.useCount }
    }

    // MARK: - 永続化

    func reload() {
        load()
    }

    private func load() {
        var readError: NSError?
        coordinator.coordinate(readingItemAt: fileURL, options: [], error: &readError) { url in
            guard FileManager.default.fileExists(atPath: url.path) else { return }
            do {
                let data = try Data(contentsOf: url)
                self.symptoms = try JSONDecoder.appDecoder.decode([CustomSymptom].self, from: data)
            } catch {
                print("[CustomSymptomStore] load error: \(error)")
                symptoms = []
            }
        }
    }

    private func save() {
        var writeError: NSError?
        coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: &writeError) { url in
            do {
                let data = try JSONEncoder.appEncoder.encode(symptoms)
                try data.write(to: url, options: .atomic)
            } catch {
                print("[CustomSymptomStore] save error: \(error)")
            }
        }
    }
}
