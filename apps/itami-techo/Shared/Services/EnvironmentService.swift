import Foundation
import CoreLocation

/// 記録時に環境データを一括取得し、EnvironmentSnapshot を生成する統合サービス
/// LocationService + WeatherService + PressureHistoryStore を組み合わせる
@Observable
final class EnvironmentService {
    let locationService = LocationService()
    let weatherService = WeatherDataService()
    let pressureHistory = PressureHistoryStore()

    /// 記録時に環境スナップショットを生成
    /// 位置情報が取れない場合は気圧のみのスナップショットを返す
    func createSnapshot() async -> EnvironmentSnapshot {
        var snapshot = EnvironmentSnapshot()

        // 1. 気圧（端末センサー — 位置不要、オフライン可）
        if let pressure = await pressureHistory.fetchCurrentPressure() {
            snapshot.pressure = pressure
            snapshot.pressureTrend3h = pressureHistory.pressureTrend3h
        }

        // 2. 位置情報
        guard let location = await locationService.requestLocation() else {
            // 位置が取れない場合は気圧だけで返す
            return snapshot
        }
        snapshot.locationApprox = await locationService.approximate(from: location)

        // 3. 天気（WeatherKit — 位置必要、ネットワーク必要）
        if let weather = await weatherService.fetchWeather(at: location) {
            snapshot.weatherCondition = weather.condition
            snapshot.temperature = weather.temperature
            snapshot.humidity = weather.humidity
            // WeatherKit の気圧がある場合はそちらを優先（より正確）
            // ただしセンサー値も保持済みなので上書きはしない
        } else {
            // WeatherKit 失敗 → 補完対象にする
            snapshot.needsBackfill = true
            snapshot.backfillDeadline = Date().addingTimeInterval(24 * 3600)
        }

        // 4. 空気質
        if let aq = await weatherService.fetchAirQuality(at: location) {
            snapshot.airQualityIndex = aq.index
            snapshot.pm25 = aq.pm25
        }

        return snapshot
    }

    /// 補完が必要な記録の天気データを後から取得
    func backfillSnapshot(_ snapshot: EnvironmentSnapshot, recordDate: Date) async -> EnvironmentSnapshot? {
        guard snapshot.needsBackfill == true,
              let deadline = snapshot.backfillDeadline,
              Date() < deadline,
              let approx = snapshot.locationApprox
        else { return nil }

        let location = CLLocation(latitude: approx.latitude, longitude: approx.longitude)
        guard let weather = await weatherService.fetchHistoricalWeather(at: location, date: recordDate) else {
            return nil
        }

        var updated = snapshot
        updated.weatherCondition = weather.condition
        updated.temperature = weather.temperature
        updated.humidity = weather.humidity
        updated.needsBackfill = false
        updated.backfillDeadline = nil
        return updated
    }

    /// 起動時に補完が必要な記録を処理
    func processBackfills(store: RecordStore) async {
        let pendingRecords = store.records.filter { $0.environment?.needsBackfill == true }
        for record in pendingRecords {
            guard let env = record.environment else { continue }
            if let updated = await backfillSnapshot(env, recordDate: record.createdAt) {
                store.attachEnvironment(id: record.id, snapshot: updated)
            }
        }
    }
}
