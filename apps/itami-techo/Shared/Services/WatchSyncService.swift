import Foundation
import WatchConnectivity

/// Watch ↔ iPhone 間のリアルタイム同期サービス
/// transferUserInfo で記録イベントを即時伝搬する
@Observable
final class WatchSyncService: NSObject, WCSessionDelegate {
    static let shared = WatchSyncService()

    private(set) var isReachable = false

    /// 新しい記録が相手デバイスから届いた時のコールバック
    var onRecordReceived: ((SymptomRecord) -> Void)?
    /// 記録更新（服薬・落ち着いた等）が届いた時のコールバック
    var onRecordUpdated: ((SymptomRecord) -> Void)?
    /// 記録削除が届いた時のコールバック
    var onRecordDeleted: ((UUID) -> Void)?

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - 送信

    /// 新しい記録を相手デバイスに送信
    func sendRecord(_ record: SymptomRecord) {
        guard WCSession.default.activationState == .activated else { return }
        do {
            let data = try JSONEncoder.appEncoder.encode(record)
            WCSession.default.transferUserInfo([
                "type": "newRecord",
                "data": data,
            ])
        } catch {
            print("[WatchSync] encode error: \(error)")
        }
    }

    /// 記録の更新を相手デバイスに送信
    func sendRecordUpdate(_ record: SymptomRecord) {
        guard WCSession.default.activationState == .activated else { return }
        do {
            let data = try JSONEncoder.appEncoder.encode(record)
            WCSession.default.transferUserInfo([
                "type": "updateRecord",
                "data": data,
            ])
        } catch {
            print("[WatchSync] encode error: \(error)")
        }
    }

    /// 記録の削除を相手デバイスに送信
    func sendRecordDeletion(id: UUID) {
        guard WCSession.default.activationState == .activated else { return }
        WCSession.default.transferUserInfo([
            "type": "deleteRecord",
            "id": id.uuidString,
        ])
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("[WatchSync] activation error: \(error)")
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let type = userInfo["type"] as? String else { return }

        switch type {
        case "newRecord":
            guard let data = userInfo["data"] as? Data,
                  let record = try? JSONDecoder.appDecoder.decode(SymptomRecord.self, from: data) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onRecordReceived?(record)
            }

        case "updateRecord":
            guard let data = userInfo["data"] as? Data,
                  let record = try? JSONDecoder.appDecoder.decode(SymptomRecord.self, from: data) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onRecordUpdated?(record)
            }

        case "deleteRecord":
            guard let idString = userInfo["id"] as? String,
                  let id = UUID(uuidString: idString) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onRecordDeleted?(id)
            }

        default:
            break
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isReachable = session.isReachable
        }
    }
}
