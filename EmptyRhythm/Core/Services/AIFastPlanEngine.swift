import Foundation

// MARK: - AI 断食方案引擎（Foundation Models + 规则引擎降级）
final class AIFastPlanEngine {

    static let shared = AIFastPlanEngine()
    private init() {}

    // MARK: - 推荐方案（主入口）
    func recommendPlan(for profile: UserProfileModel) -> FastPlanModel {
        // iOS 18.1+ Apple Intelligence 设备：使用 Foundation Models
        // 其他设备：降级为规则引擎
        if #available(iOS 18.1, *) {
            return ruleBasedRecommendation(for: profile)
            // TODO: 集成 Foundation Models 后替换为 AI 推理
        } else {
            return ruleBasedRecommendation(for: profile)
        }
    }

    // MARK: - 规则引擎（硬编码，全设备可用）
    func ruleBasedRecommendation(for profile: UserProfileModel) -> FastPlanModel {
        let bmi = profile.bmiCategory
        let gender = profile.gender
        let isGastro = profile.isGastroSensitive
        let isPeriodSensitive = profile.isGirlPeriodSensitive

        // 偏瘦：养生调理
        if bmi == .underweight {
            return FastPlanModel(
                id: "ai_underweight",
                name: L("plan.ai.wellness"),
                fastHour: 12, eatHour: 12,
                startTime: "20:00", endTime: "08:00",
                isAICustom: true,
                planDesc: L("plan.ai.wellness.desc"),
                isCurrentUse: false
            )
        }

        // 女性敏感体质
        if gender == .female && (isGastro || isPeriodSensitive) {
            return FastPlanModel(
                id: "ai_female_sensitive",
                name: L("plan.ai.gentle"),
                fastHour: 14, eatHour: 10,
                startTime: "20:00", endTime: "10:00",
                isAICustom: true,
                planDesc: L("plan.ai.gentle.desc"),
                isCurrentUse: false
            )
        }

        // 标准体重
        if bmi == .normal {
            return FastPlanModel(
                id: "ai_normal",
                name: L("plan.16_8"),
                fastHour: 16, eatHour: 8,
                startTime: "20:00", endTime: "12:00",
                isAICustom: true,
                planDesc: L("plan.ai.normal.desc"),
                isCurrentUse: false
            )
        }

        // 超重
        if bmi == .overweight {
            let hour = gender == .male ? 18 : 16
            let eatHour = 24 - hour
            return FastPlanModel(
                id: "ai_overweight",
                name: "\(hour):\(eatHour)",
                fastHour: hour, eatHour: eatHour,
                startTime: "20:00", endTime: hour == 18 ? "14:00" : "12:00",
                isAICustom: true,
                planDesc: L("plan.ai.overweight.desc"),
                isCurrentUse: false
            )
        }

        // 肥胖：梯度进阶（新手从 12:12 开始）
        let isNewbie = profile.age < 25 || !UserDefaults.standard.bool(forKey: "er_has_fasted_before")
        if isNewbie {
            return FastPlanModel(
                id: "ai_obese_beginner",
                name: L("plan.12_12"),
                fastHour: 12, eatHour: 12,
                startTime: "20:00", endTime: "08:00",
                isAICustom: true,
                planDesc: L("plan.ai.beginner.desc"),
                isCurrentUse: false
            )
        }

        return FastPlanModel(
            id: "ai_obese",
            name: L("plan.16_8"),
            fastHour: 16, eatHour: 8,
            startTime: "20:00", endTime: "12:00",
            isAICustom: true,
            planDesc: L("plan.ai.obese.desc"),
            isCurrentUse: false
        )
    }

    // MARK: - AI 周复盘生成
    func generateWeeklyReport(
        fastRecords: [FastRecord],
        weightChange: Double,
        completion: @escaping (String) -> Void
    ) {
        let successCount = fastRecords.filter { $0.status == 1 }.count
        let failCount = fastRecords.filter { $0.status == 2 }.count
        let totalCount = fastRecords.count
        let completionRate = totalCount > 0 ? Double(successCount) / Double(totalCount) : 0

        // 规则引擎生成复盘文案
        var report = ""

        if completionRate >= 0.8 {
            report += L("report.excellent_execution") + "\n\n"
        } else if completionRate >= 0.5 {
            report += L("report.good_execution") + "\n\n"
        } else {
            report += L("report.need_improvement") + "\n\n"
        }

        if weightChange < -0.5 {
            report += String(format: L("report.weight_down"), abs(weightChange)) + "\n"
        } else if weightChange > 0.5 {
            report += String(format: L("report.weight_up"), weightChange) + "\n"
        } else {
            report += L("report.weight_stable") + "\n"
        }

        report += "\n" + L("report.next_week_tip")

        completion(report)
    }
}
