import Foundation
import CoreData

// MARK: - 用户档案服务
final class UserProfileService {

    static let shared = UserProfileService()
    private init() {}

    private var _profile: UserProfileModel?

    var hasProfile: Bool { currentProfile != nil }

    var currentProfile: UserProfileModel? {
        if let cached = _profile { return cached }
        return loadFromCoreData()
    }

    func save(profile: UserProfileModel) {
        _profile = profile
        saveToCorData(profile: profile)
    }

    func update(weight: Double) {
        guard var p = currentProfile else { return }
        p.currentWeight = weight
        save(profile: p)
    }

    // MARK: - CoreData 读写
    private func loadFromCoreData() -> UserProfileModel? {
        let ctx = CoreDataManager.shared.context
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        req.fetchLimit = 1
        guard let entity = try? ctx.fetch(req).first else { return nil }

        let profile = UserProfileModel(
            userID: entity.userID ?? "",
            gender: Gender(rawValue: entity.gender) ?? .female,
            age: Int(entity.age),
            height: entity.height,
            currentWeight: entity.currentWeight,
            targetWeight: entity.targetWeight,
            sportLevel: SportLevel(rawValue: entity.sportLevel) ?? .sedentary,
            workRestType: WorkRestType(rawValue: entity.workRestType) ?? .regular,
            isGastroSensitive: entity.isGastroSensitive,
            isGirlPeriodSensitive: entity.isGirlPeriodSensitive
        )
        _profile = profile
        return profile
    }

    private func saveToCorData(profile: UserProfileModel) {
        let ctx = CoreDataManager.shared.context
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        req.fetchLimit = 1
        let entity = (try? ctx.fetch(req).first) ?? UserProfile(context: ctx)

        entity.userID = profile.userID
        entity.gender = profile.gender.rawValue
        entity.age = Int16(profile.age)
        entity.height = profile.height
        entity.currentWeight = profile.currentWeight
        entity.targetWeight = profile.targetWeight
        entity.bmi = profile.bmi
        entity.bmr = profile.bmr
        entity.dailyCalorieStandard = profile.dailyCalorieStandard
        entity.sportLevel = profile.sportLevel.rawValue
        entity.workRestType = profile.workRestType.rawValue
        entity.isGastroSensitive = profile.isGastroSensitive
        entity.isGirlPeriodSensitive = profile.isGirlPeriodSensitive
        entity.updateTime = Date()

        CoreDataManager.shared.save()
    }
}
