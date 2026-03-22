import Foundation

/// 症状記録の永続化ストア
/// NSFileCoordinator で Watch↔iPhone 間の同時アクセスを安全に処理する
@Observable
final class RecordStore {
    private(set) var records: [SymptomRecord] = []
    private let fileURL: URL
    private let backupURL: URL
    private let coordinator = NSFileCoordinator()

    init() {
        let container = AppConstants.sharedContainerURL
        self.fileURL = container.appendingPathComponent(AppConstants.recordsFileName)
        self.backupURL = container.appendingPathComponent(AppConstants.recordsBackupFileName)
        load()
    }

    // MARK: - CRUD

    func add(_ record: SymptomRecord) {
        // WatchSync 経由で同一レコードが複数回届く可能性があるため重複チェック
        guard !records.contains(where: { $0.id == record.id }) else { return }
        records.append(record)
        records.sort { $0.createdAt > $1.createdAt }
        save()
    }

    func update(_ record: SymptomRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        var updated = record
        updated.updatedAt = Date()
        records[index] = updated
        save()
    }

    func delete(id: UUID) {
        records.removeAll { $0.id == id }
        save()
    }

    /// 服薬を記録
    func markMedicationTaken(id: UUID, at date: Date = Date(), medicationId: UUID? = nil, medicationName: String? = nil) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].medicationTaken = true
        records[index].medicationTakenAt = date
        records[index].customMedicationId = medicationId
        records[index].customMedicationName = medicationName
        records[index].updatedAt = Date()
        save()
    }

    /// 落ち着いた時刻を記録
    func markSettled(id: UUID, at date: Date = Date()) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].settledAt = date
        records[index].updatedAt = Date()
        save()
    }

    /// 環境データを後付け
    func attachEnvironment(id: UUID, snapshot: EnvironmentSnapshot) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].environment = snapshot
        records[index].updatedAt = Date()
        save()
    }

    /// Health データを後付け
    func attachHealth(id: UUID, snapshot: HealthSnapshot) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].healthSummary = snapshot
        records[index].updatedAt = Date()
        save()
    }

    // MARK: - クエリ

    /// 今日の記録
    var todayRecords: [SymptomRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDateInToday($0.createdAt) }
    }

    /// 直近の記録（1件）
    var latestRecord: SymptomRecord? {
        records.first
    }

    /// 指定日数分の記録
    func records(lastDays days: Int) -> [SymptomRecord] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return records.filter { $0.createdAt >= cutoff }
    }

    /// 指定期間の記録
    func records(from start: Date, to end: Date) -> [SymptomRecord] {
        records.filter { $0.createdAt >= start && $0.createdAt <= end }
    }

    // MARK: - 永続化（NSFileCoordinator 付き）

    func reload() {
        load()
    }

    private func load() {
        var readError: NSError?
        coordinator.coordinate(readingItemAt: fileURL, options: [], error: &readError) { url in
            guard FileManager.default.fileExists(atPath: url.path) else { return }
            do {
                let data = try Data(contentsOf: url)
                self.records = try JSONDecoder.appDecoder.decode([SymptomRecord].self, from: data)
            } catch {
                // メインファイルが壊れていたらバックアップから復旧
                recoverFromBackup()
            }
        }
        if let readError {
            print("[RecordStore] coordinate read error: \(readError)")
        }
    }

    private func save() {
        var writeError: NSError?
        coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: &writeError) { url in
            do {
                // バックアップを保持
                if FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: backupURL)
                    try? FileManager.default.copyItem(at: url, to: backupURL)
                }
                let data = try JSONEncoder.appEncoder.encode(records)
                try data.write(to: url, options: .atomic)
            } catch {
                print("[RecordStore] save error: \(error)")
            }
        }
        if let writeError {
            print("[RecordStore] coordinate write error: \(writeError)")
        }
    }

    private func recoverFromBackup() {
        guard FileManager.default.fileExists(atPath: backupURL.path) else {
            print("[RecordStore] No backup available, starting fresh")
            records = []
            return
        }
        do {
            let data = try Data(contentsOf: backupURL)
            records = try JSONDecoder.appDecoder.decode([SymptomRecord].self, from: data)
            print("[RecordStore] Recovered from backup (\(records.count) records)")
            save() // バックアップ内容でメインファイルを復元
        } catch {
            print("[RecordStore] Backup also corrupted, starting fresh: \(error)")
            records = []
        }
    }
}

// MARK: - JSON Coding

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
