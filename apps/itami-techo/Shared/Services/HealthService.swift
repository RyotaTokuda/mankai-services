import Foundation
import HealthKit

/// HealthKit からデータを読み取り、HealthSnapshot を生成するサービス
/// データは読み取りのみ。書き込みは行わない。
@Observable
final class HealthService {
    private let store = HKHealthStore()
    private(set) var isAuthorized = false

    /// HealthKit が利用可能かどうか
    static var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// 読み取り対象の型
    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(sleep) }
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) { types.insert(hr) }
        if let rhr = HKObjectType.quantityType(forIdentifier: .restingHeartRate) { types.insert(rhr) }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { types.insert(hrv) }
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        if let resp = HKObjectType.quantityType(forIdentifier: .respiratoryRate) { types.insert(resp) }
        if let workout = HKObjectType.workoutType() as? HKObjectType { types.insert(workout) }
        return types
    }

    // MARK: - 権限リクエスト

    func requestAuthorization() async -> Bool {
        guard HealthService.isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            print("[HealthService] authorization error: \(error)")
            return false
        }
    }

    // MARK: - スナップショット生成

    /// 現在時点の Health データからスナップショットを生成
    func createSnapshot() async -> HealthSnapshot {
        guard HealthService.isAvailable, isAuthorized else { return HealthSnapshot() }
        var snapshot = HealthSnapshot()

        async let sleep = fetchLastNightSleep()
        async let hr = fetchRecentHeartRate()
        async let rhr = fetchRestingHeartRate()
        async let hrv = fetchHeartRateVariability()
        async let steps = fetchTodaySteps()
        async let resp = fetchRespiratoryRate()
        async let workout = fetchTodayWorkout()

        snapshot.sleepDurationHours = await sleep
        snapshot.avgHeartRate = await hr
        snapshot.restingHeartRate = await rhr
        snapshot.heartRateVariability = await hrv
        snapshot.stepCount = await steps
        snapshot.respiratoryRate = await resp
        snapshot.hadWorkout = await workout

        return snapshot
    }

    // MARK: - 個別データ取得

    private func fetchLastNightSleep() async -> Double? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                // asleepUnspecified, asleepCore, asleepDeep, asleepREM を合算
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                ]
                let totalSeconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                let hours = totalSeconds / 3600.0
                continuation.resume(returning: hours > 0 ? hours : nil)
            }
            store.execute(query)
        }
    }

    private func fetchRecentHeartRate() async -> Double? {
        await fetchLatestQuantity(identifier: .heartRate, unit: HKUnit.count().unitDivided(by: .minute()))
    }

    private func fetchRestingHeartRate() async -> Double? {
        await fetchLatestQuantity(identifier: .restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
    }

    private func fetchHeartRateVariability() async -> Double? {
        await fetchLatestQuantity(identifier: .heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
    }

    private func fetchRespiratoryRate() async -> Double? {
        await fetchLatestQuantity(identifier: .respiratoryRate, unit: HKUnit.count().unitDivided(by: .minute()))
    }

    private func fetchTodaySteps() async -> Int? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: .count())
                continuation.resume(returning: steps.map { Int($0) })
            }
            store.execute(query)
        }
    }

    private func fetchTodayWorkout() async -> Bool? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, _ in
                continuation.resume(returning: !(samples?.isEmpty ?? true))
            }
            store.execute(query)
        }
    }

    // MARK: - ヘルパー

    private func fetchLatestQuantity(identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }
}
