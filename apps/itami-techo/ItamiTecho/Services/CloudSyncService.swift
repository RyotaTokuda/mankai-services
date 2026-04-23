import Foundation

/// iCloud Drive バックアップ・機種変対応サービス
///
/// データの流れ:
///   記録 → App Group JSON（Watch との共有プライマリ）
///           ↕ アプリ起動・バックグラウンド時
///       iCloud Drive JSON（自動的に Apple のサーバーへ）
///           ↕ 新しい端末でアプリ初回起動時
///   新端末 App Group JSON（自動復元）
final class CloudSyncService {
    static let containerID = "iCloud.com.mankai.itamitecho"

    private var documentsURL: URL?

    /// iCloud が利用可能か（サインイン済みか）
    var isAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    /// iCloud コンテナを初期化（バックグラウンドで実行）
    func setup() async {
        guard documentsURL == nil else { return }
        let base: URL? = await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .utility).async {
                cont.resume(returning: FileManager.default.url(
                    forUbiquityContainerIdentifier: Self.containerID
                ))
            }
        }
        guard let base else { return }
        let docs = base.appendingPathComponent("Documents", isDirectory: true)
        try? FileManager.default.createDirectory(at: docs, withIntermediateDirectories: true)
        documentsURL = docs
    }

    // MARK: - Push（ローカル → iCloud）

    func push(records: [SymptomRecord], symptoms: [CustomSymptom]) async {
        await Task.detached(priority: .utility) {
            self.writeJSON(records, filename: AppConstants.recordsFileName)
            self.writeJSON(symptoms, filename: AppConstants.customSymptomsFileName)
        }.value
    }

    // MARK: - Pull（iCloud → ローカル）

    func pullRecords() async -> [SymptomRecord]? {
        await Task.detached(priority: .utility) {
            self.readJSON(filename: AppConstants.recordsFileName)
        }.value
    }

    func pullSymptoms() async -> [CustomSymptom]? {
        await Task.detached(priority: .utility) {
            self.readJSON(filename: AppConstants.customSymptomsFileName)
        }.value
    }

    // MARK: - Private

    private func writeJSON<T: Encodable>(_ value: T, filename: String) {
        guard let url = documentsURL?.appendingPathComponent(filename) else { return }
        do {
            let data = try JSONEncoder.appEncoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("[CloudSync] write \(filename): \(error)")
        }
    }

    private func readJSON<T: Decodable>(filename: String) -> T? {
        guard let url = documentsURL?.appendingPathComponent(filename),
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        // iCloud にあってローカル未ダウンロードの場合にダウンロード開始
        try? FileManager.default.startDownloadingUbiquitousItem(at: url)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder.appDecoder.decode(T.self, from: data)
        } catch {
            print("[CloudSync] read \(filename): \(error)")
            return nil
        }
    }
}
