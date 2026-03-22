import Foundation
import CoreMotion

/// CMAltimeter で端末内蔵気圧センサーからリアルタイム気圧を取得し、
/// 直近の履歴を保持して気圧変化量を算出するサービス
@Observable
final class PressureHistoryStore {
    private let altimeter = CMAltimeter()
    private(set) var currentPressure: Double?
    private(set) var readings: [PressureReading] = []

    private let maxReadings = 36 // 3時間分（5分間隔）
    private let fileURL: URL

    struct PressureReading: Codable {
        let date: Date
        let pressure: Double // kPa → hPa に変換して保存
    }

    init() {
        self.fileURL = AppConstants.sharedContainerURL
            .appendingPathComponent("pressure_history.json")
        loadReadings()
    }

    /// 気圧センサーが利用可能か
    static var isAvailable: Bool {
        CMAltimeter.isRelativeAltitudeAvailable()
    }

    // MARK: - リアルタイム取得

    /// 現在の気圧を1回だけ取得（hPa）
    func fetchCurrentPressure() async -> Double? {
        guard PressureHistoryStore.isAvailable else { return nil }

        return await withCheckedContinuation { continuation in
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
                self?.altimeter.stopRelativeAltitudeUpdates()
                guard let data, error == nil else {
                    continuation.resume(returning: nil)
                    return
                }
                // kPa → hPa
                let pressureHPa = data.pressure.doubleValue * 10.0
                self?.currentPressure = pressureHPa
                self?.addReading(pressure: pressureHPa)
                continuation.resume(returning: pressureHPa)
            }
        }
    }

    // MARK: - 気圧変化量

    /// 直近3時間の気圧変化量（hPa）
    var pressureTrend3h: Double? {
        let threeHoursAgo = Date().addingTimeInterval(-3 * 3600)
        guard let oldest = readings.first(where: { $0.date >= threeHoursAgo }),
              let newest = readings.last
        else { return nil }
        return newest.pressure - oldest.pressure
    }

    // MARK: - 履歴管理

    private func addReading(pressure: Double) {
        let reading = PressureReading(date: Date(), pressure: pressure)
        readings.append(reading)
        // 古い読み取りを削除
        if readings.count > maxReadings {
            readings.removeFirst(readings.count - maxReadings)
        }
        saveReadings()
    }

    private func loadReadings() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            readings = try JSONDecoder.appDecoder.decode([PressureReading].self, from: data)
            // 24時間以上古い読み取りを削除
            let cutoff = Date().addingTimeInterval(-24 * 3600)
            readings.removeAll { $0.date < cutoff }
        } catch {
            readings = []
        }
    }

    private func saveReadings() {
        do {
            let data = try JSONEncoder.appEncoder.encode(readings)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[PressureHistory] save error: \(error)")
        }
    }
}
