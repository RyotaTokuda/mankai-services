import Foundation
import WeatherKit
import CoreLocation

/// WeatherKit で天気データを取得するサービス
/// 名前衝突を避けるため WeatherDataService とする
@Observable
final class WeatherDataService {
    private let service = WeatherKit.WeatherService.shared

    // MARK: - WeatherKit

    /// 指定位置の現在の天気データを取得
    func fetchWeather(at location: CLLocation) async -> WeatherSnapshot? {
        do {
            let weather = try await service.weather(for: location)
            let current = weather.currentWeather

            return WeatherSnapshot(
                condition: current.condition.description,
                temperature: current.temperature.value,
                humidity: current.humidity * 100,
                pressure: current.pressure.value
            )
        } catch {
            print("[WeatherDataService] weather fetch error: \(error)")
            return nil
        }
    }

    /// 指定位置の過去天気を取得（補完用）
    func fetchHistoricalWeather(at location: CLLocation, date: Date) async -> WeatherSnapshot? {
        do {
            let weather = try await service.weather(
                for: location,
                including: .hourly(startDate: date, endDate: date.addingTimeInterval(3600))
            )
            guard let hourly = weather.first else { return nil }
            return WeatherSnapshot(
                condition: hourly.condition.description,
                temperature: hourly.temperature.value,
                humidity: hourly.humidity * 100,
                pressure: hourly.pressure.value
            )
        } catch {
            print("[WeatherDataService] historical weather error: \(error)")
            return nil
        }
    }

    /// 空気質データを取得
    func fetchAirQuality(at location: CLLocation) async -> AirQualityData? {
        // WeatherKit の空気質は一部地域のみ対応
        // 取得できない場合は nil を返す
        return nil
    }

    // MARK: - 予報取得（予兆通知用）

    /// 今後24時間の気圧予報を取得
    func fetchPressureForecast(at location: CLLocation) async -> [PressureForecastPoint] {
        do {
            let endDate = Date().addingTimeInterval(24 * 3600)
            let weather = try await service.weather(
                for: location,
                including: .hourly(startDate: Date(), endDate: endDate)
            )
            return weather.map { hourly in
                PressureForecastPoint(
                    date: hourly.date,
                    pressure: hourly.pressure.value
                )
            }
        } catch {
            print("[WeatherDataService] forecast error: \(error)")
            return []
        }
    }
}

/// WeatherKit から取得した天気データ（内部用）
struct WeatherSnapshot {
    let condition: String
    let temperature: Double
    let humidity: Double
    let pressure: Double
}

/// 空気質データ（内部用）
struct AirQualityData {
    let index: Int
    let pm25: Double?
}

/// 気圧予報ポイント（予兆通知用）
struct PressureForecastPoint {
    let date: Date
    let pressure: Double
}
