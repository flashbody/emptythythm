import Foundation
import HealthKit
import CoreData

// MARK: - HealthKit 服务
final class HealthKitService {

    static let shared = HealthKitService()
    private init() {}

    private let store = HKHealthStore()

    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.categoryType(forIdentifier: .appleStandHour)!
    ]

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - 请求权限（用户点击功能时才调用）
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isAvailable else { completion(false); return }
        store.requestAuthorization(toShare: [], read: readTypes) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - 同步今日数据
    func syncTodayData(completion: @escaping (HealthDayData) -> Void) {
        let group = DispatchGroup()
        var data = HealthDayData()
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

        // 步数
        group.enter()
        querySum(type: .stepCount, unit: .count(), predicate: predicate) { value in
            data.stepCount = Int(value ?? 0)
            group.leave()
        }

        // 跑步距离
        group.enter()
        querySum(type: .distanceWalkingRunning, unit: .meter(), predicate: predicate) { value in
            data.runDistance = (value ?? 0) / 1000  // 转 km
            group.leave()
        }

        // 主动卡路里
        group.enter()
        querySum(type: .activeEnergyBurned, unit: .kilocalorie(), predicate: predicate) { value in
            data.activeCalorie = value ?? 0
            group.leave()
        }

        // 运动时长
        group.enter()
        querySum(type: .appleExerciseTime, unit: .minute(), predicate: predicate) { value in
            data.activeTime = Int(value ?? 0)
            group.leave()
        }

        // 静息心率
        group.enter()
        queryMostRecent(type: .restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()), predicate: predicate) { value in
            data.restHeartRate = Int(value ?? 0)
            group.leave()
        }

        group.notify(queue: .main) {
            data.dailyHealthScore = self.calculateHealthScore(data: data)
            data.warningDesc = self.generateWarnings(data: data)
            self.saveToCorData(data: data)
            completion(data)
        }
    }

    // MARK: - 健康评分计算
    private func calculateHealthScore(data: HealthDayData) -> Int {
        var score = 5
        if data.stepCount >= 10000 { score += 2 }
        else if data.stepCount >= 6000 { score += 1 }
        if data.activeTime >= 30 { score += 1 }
        if data.restHeartRate > 0 && data.restHeartRate < 80 { score += 1 }
        if data.activeCalorie >= 300 { score += 1 }
        return min(score, 10)
    }

    // MARK: - 风险预警生成
    private func generateWarnings(data: HealthDayData) -> String? {
        var warnings: [String] = []
        let hour = Calendar.current.component(.hour, from: Date())

        if hour >= 12 && data.stepCount < 1000 {
            warnings.append(L("health.warning.sedentary"))
        }
        if data.restHeartRate > 100 {
            warnings.append(L("health.warning.heart_rate"))
        }
        if data.activeCalorie < 100 && hour >= 18 {
            warnings.append(L("health.warning.low_activity"))
        }
        return warnings.isEmpty ? nil : warnings.joined(separator: "\n")
    }

    // MARK: - CoreData 存储
    private func saveToCorData(data: HealthDayData) {
        let ctx = CoreDataManager.shared.context
        let req: NSFetchRequest<HealthRecord> = HealthRecord.fetchRequest()
        let today = Calendar.current.startOfDay(for: Date())
        req.predicate = NSPredicate(format: "recordDate == %@", today as NSDate)
        req.fetchLimit = 1

        let record = (try? ctx.fetch(req).first) ?? HealthRecord(context: ctx)
        record.healthID = record.healthID ?? UUID().uuidString
        record.recordDate = today
        record.stepCount = Int32(data.stepCount)
        record.runDistance = data.runDistance
        record.activeCalorie = data.activeCalorie
        record.activeTime = Int32(data.activeTime)
        record.restHeartRate = Int16(data.restHeartRate)
        record.dailyHealthScore = Int16(data.dailyHealthScore)
        record.healthWarningDesc = data.warningDesc
        record.createTime = Date()
        CoreDataManager.shared.save()
    }

    // MARK: - 通用查询
    private func querySum(
        type identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        predicate: NSPredicate,
        completion: @escaping (Double?) -> Void
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(nil); return
        }
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            completion(result?.sumQuantity()?.doubleValue(for: unit))
        }
        store.execute(query)
    }

    private func queryMostRecent(
        type identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        predicate: NSPredicate,
        completion: @escaping (Double?) -> Void
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(nil); return
        }
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .discreteMostRecent
        ) { _, result, _ in
            completion(result?.mostRecentQuantity()?.doubleValue(for: unit))
        }
        store.execute(query)
    }
}

// MARK: - 今日健康数据
struct HealthDayData {
    var stepCount: Int = 0
    var runDistance: Double = 0    // km
    var activeCalorie: Double = 0  // kcal
    var activeTime: Int = 0        // min
    var restHeartRate: Int = 0
    var dailyHealthScore: Int = 0
    var warningDesc: String?
}
