import Foundation
import CoreLocation

/// 記録時の位置情報を取得するサービス
/// When In Use 権限のみ使用。記録時の一度だけ取得する。
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?

    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer // 市区町村レベルで十分
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - 権限

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    // MARK: - 位置取得

    /// 現在地を1回だけ取得
    func requestLocation() async -> CLLocation? {
        guard isAuthorized else { return nil }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    /// CLLocation から LocationApprox に変換（市区町村レベルに丸める）
    func approximate(from location: CLLocation) async -> LocationApprox {
        let geocoder = CLGeocoder()
        let city = try? await geocoder.reverseGeocodeLocation(location).first?.locality
        // 小数2桁に丸める（約1km精度）
        let lat = (location.coordinate.latitude * 100).rounded() / 100
        let lon = (location.coordinate.longitude * 100).rounded() / 100
        return LocationApprox(latitude: lat, longitude: lon, city: city)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations.last)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationService] location error: \(error)")
        continuation?.resume(returning: nil)
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
