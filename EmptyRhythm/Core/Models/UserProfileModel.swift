import Foundation
import UIKit

// MARK: - 用户体质档案（值类型，从 CoreData 映射）
struct UserProfileModel {
    var userID: String
    var gender: Gender
    var age: Int
    var height: Double       // cm
    var currentWeight: Double // kg
    var targetWeight: Double  // kg
    var sportLevel: SportLevel
    var workRestType: WorkRestType
    var isGastroSensitive: Bool
    var isGirlPeriodSensitive: Bool

    // 自动计算字段
    var bmi: Double { currentWeight / ((height / 100) * (height / 100)) }
    var bmiCategory: BMICategory { BMICategory(bmi: bmi) }

    /// 基础代谢率 Harris-Benedict 公式
    var bmr: Double {
        switch gender {
        case .female:
            return 655.1 + (9.563 * currentWeight) + (1.850 * height) - (4.676 * Double(age))
        case .male:
            return 66.47 + (13.75 * currentWeight) + (5.003 * height) - (6.755 * Double(age))
        }
    }

    /// 每日推荐摄入热量（TDEE）
    var dailyCalorieStandard: Double {
        bmr * sportLevel.activityFactor
    }

    /// 合理热量缺口（减脂目标）
    var calorieDeficit: Double {
        guard bmiCategory != .underweight else { return 0 }
        return min(dailyCalorieStandard * 0.2, 500)
    }

    /// 每日目标摄入热量
    var dailyTargetCalorie: Double {
        max(dailyCalorieStandard - calorieDeficit, gender == .female ? 1200 : 1500)
    }
}

// MARK: - 性别
enum Gender: Int16, CaseIterable {
    case female = 0
    case male = 1

    var displayName: String {
        switch self {
        case .female: return L("gender.female")
        case .male: return L("gender.male")
        }
    }
}

// MARK: - BMI 分类
enum BMICategory {
    case underweight   // < 18.5
    case normal        // 18.5 - 23.9
    case overweight    // 24.0 - 27.9
    case obese         // >= 28.0

    init(bmi: Double) {
        switch bmi {
        case ..<18.5:   self = .underweight
        case 18.5..<24: self = .normal
        case 24..<28:   self = .overweight
        default:        self = .obese
        }
    }

    var displayName: String {
        switch self {
        case .underweight: return L("bmi.underweight")
        case .normal:      return L("bmi.normal")
        case .overweight:  return L("bmi.overweight")
        case .obese:       return L("bmi.obese")
        }
    }

    var color: UIColor {
        switch self {
        case .underweight: return AppColor.aiBlue
        case .normal:      return AppColor.mainTint
        case .overweight:  return AppColor.warningOrange
        case .obese:       return AppColor.danger
        }
    }
}

// MARK: - 运动强度
enum SportLevel: Int16, CaseIterable {
    case sedentary = 0   // 久坐
    case light = 1       // 轻度
    case moderate = 2    // 中度
    case intense = 3     // 高强度

    var activityFactor: Double {
        switch self {
        case .sedentary: return 1.2
        case .light:     return 1.375
        case .moderate:  return 1.55
        case .intense:   return 1.725
        }
    }

    var displayName: String {
        switch self {
        case .sedentary: return L("sport.sedentary")
        case .light:     return L("sport.light")
        case .moderate:  return L("sport.moderate")
        case .intense:   return L("sport.intense")
        }
    }
}

// MARK: - 作息类型
enum WorkRestType: Int16, CaseIterable {
    case regular = 0    // 规律
    case nightOwl = 1   // 熬夜

    var displayName: String {
        switch self {
        case .regular:  return L("workrest.regular")
        case .nightOwl: return L("workrest.nightowl")
        }
    }
}
