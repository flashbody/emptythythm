import Foundation

// MARK: - 断食方案模型
struct FastPlanModel: Identifiable {
    let id: String
    var name: String
    var fastHour: Int      // 断食时长（小时）
    var eatHour: Int       // 进食时长（小时）
    var startTime: String  // "20:00"
    var endTime: String    // "12:00"
    var isAICustom: Bool
    var planDesc: String
    var isCurrentUse: Bool

    var displayName: String { "\(fastHour):\(eatHour)" }

    var totalHours: Int { fastHour + eatHour }
}

// MARK: - 预设方案库
enum PresetFastPlan: CaseIterable {
    case h12_12   // 新手入门
    case h14_10   // 轻度
    case h16_8    // 经典（最流行）
    case h18_6    // 进阶
    case h20_4    // 高强度（男性专属）
    case h5_2     // 5:2 轻断食

    var model: FastPlanModel {
        switch self {
        case .h12_12:
            return FastPlanModel(id: "preset_12_12", name: L("plan.12_12"), fastHour: 12, eatHour: 12,
                                 startTime: "20:00", endTime: "08:00", isAICustom: false,
                                 planDesc: L("plan.12_12.desc"), isCurrentUse: false)
        case .h14_10:
            return FastPlanModel(id: "preset_14_10", name: L("plan.14_10"), fastHour: 14, eatHour: 10,
                                 startTime: "20:00", endTime: "10:00", isAICustom: false,
                                 planDesc: L("plan.14_10.desc"), isCurrentUse: false)
        case .h16_8:
            return FastPlanModel(id: "preset_16_8", name: L("plan.16_8"), fastHour: 16, eatHour: 8,
                                 startTime: "20:00", endTime: "12:00", isAICustom: false,
                                 planDesc: L("plan.16_8.desc"), isCurrentUse: false)
        case .h18_6:
            return FastPlanModel(id: "preset_18_6", name: L("plan.18_6"), fastHour: 18, eatHour: 6,
                                 startTime: "20:00", endTime: "14:00", isAICustom: false,
                                 planDesc: L("plan.18_6.desc"), isCurrentUse: false)
        case .h20_4:
            return FastPlanModel(id: "preset_20_4", name: L("plan.20_4"), fastHour: 20, eatHour: 4,
                                 startTime: "20:00", endTime: "16:00", isAICustom: false,
                                 planDesc: L("plan.20_4.desc"), isCurrentUse: false)
        case .h5_2:
            return FastPlanModel(id: "preset_5_2", name: L("plan.5_2"), fastHour: 24, eatHour: 0,
                                 startTime: "00:00", endTime: "00:00", isAICustom: false,
                                 planDesc: L("plan.5_2.desc"), isCurrentUse: false)
        }
    }

    /// 根据用户档案过滤可用方案
    static func availablePlans(for profile: UserProfileModel) -> [FastPlanModel] {
        var plans: [FastPlanModel] = []

        switch profile.bmiCategory {
        case .underweight:
            // 偏瘦：仅养生调理，最多 14:10
            plans = [h12_12.model, h14_10.model]

        case .normal:
            // 标准：16:8 维稳
            plans = [h14_10.model, h16_8.model]

        case .overweight:
            // 超重：16:8 进阶
            plans = [h16_8.model, h18_6.model]

        case .obese:
            // 肥胖：梯度进阶
            plans = [h12_12.model, h14_10.model, h16_8.model, h18_6.model]
        }

        // 女性：最高 18:6，屏蔽 20:4
        if profile.gender == .female {
            plans = plans.filter { $0.fastHour <= 18 }
        }

        // 男性超重/肥胖：开放 20:4
        if profile.gender == .male && (profile.bmiCategory == .overweight || profile.bmiCategory == .obese) {
            plans.append(h20_4.model)
        }

        // 肠胃敏感：限制最大 16:8
        if profile.isGastroSensitive {
            plans = plans.filter { $0.fastHour <= 16 }
        }

        return plans
    }
}
