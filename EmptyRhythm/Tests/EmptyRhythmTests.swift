import XCTest
@testable import EmptyRhythm

// MARK: - 核心逻辑单元测试
final class EmptyRhythmTests: XCTestCase {

    // MARK: - BMI 计算测试
    func testBMICalculation() {
        let profile = UserProfileModel(
            userID: "test", gender: .female, age: 28,
            height: 165, currentWeight: 70, targetWeight: 55,  // BMI=25.7 → overweight
            sportLevel: .light, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let bmi = profile.bmi
        XCTAssertEqual(bmi, 70 / (1.65 * 1.65), accuracy: 0.01)
        XCTAssertEqual(profile.bmiCategory, .overweight)
    }

    // MARK: - BMR 计算测试
    func testBMRCalculation_Female() {
        let profile = UserProfileModel(
            userID: "test", gender: .female, age: 30,
            height: 165, currentWeight: 60, targetWeight: 55,
            sportLevel: .sedentary, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let expected = 655.1 + (9.563 * 60) + (1.850 * 165) - (4.676 * 30)
        XCTAssertEqual(profile.bmr, expected, accuracy: 0.1)
    }

    func testBMRCalculation_Male() {
        let profile = UserProfileModel(
            userID: "test", gender: .male, age: 30,
            height: 175, currentWeight: 80, targetWeight: 70,
            sportLevel: .moderate, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let expected = 66.47 + (13.75 * 80) + (5.003 * 175) - (6.755 * 30)
        XCTAssertEqual(profile.bmr, expected, accuracy: 0.1)
    }

    // MARK: - 方案筛选测试
    func testPlanFilter_Underweight() {
        let profile = UserProfileModel(
            userID: "test", gender: .female, age: 22,
            height: 165, currentWeight: 48, targetWeight: 50,
            sportLevel: .light, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let plans = PresetFastPlan.availablePlans(for: profile)
        XCTAssertTrue(plans.allSatisfy { $0.fastHour <= 14 }, "偏瘦用户不应有超过 14h 的方案")
    }

    func testPlanFilter_FemaleMax18h() {
        let profile = UserProfileModel(
            userID: "test", gender: .female, age: 28,
            height: 165, currentWeight: 75, targetWeight: 60,
            sportLevel: .moderate, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let plans = PresetFastPlan.availablePlans(for: profile)
        XCTAssertTrue(plans.allSatisfy { $0.fastHour <= 18 }, "女性不应有超过 18h 的方案")
    }

    func testPlanFilter_MaleObese_Has20h() {
        let profile = UserProfileModel(
            userID: "test", gender: .male, age: 30,
            height: 175, currentWeight: 100, targetWeight: 80,
            sportLevel: .moderate, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let plans = PresetFastPlan.availablePlans(for: profile)
        XCTAssertTrue(plans.contains { $0.fastHour == 20 }, "肥胖男性应有 20:4 方案")
    }

    // MARK: - 计时器格式化测试
    func testTimeFormatting() {
        let timer = FastTimerManager.shared
        // 通过反射测试私有方法（通过公开接口间接验证）
        XCTAssertEqual(timer.elapsedTimeString, "00:00:00")
    }

    // MARK: - 食物库测试
    func testFoodDatabaseBuiltin() {
        let foods = FoodDatabaseService.builtinFoods()
        XCTAssertFalse(foods.isEmpty)
        XCTAssertTrue(foods.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(foods.allSatisfy { $0.caloriesPer100g > 0 })
    }

    func testFoodSearch() {
        let results = FoodDatabaseService.shared.search(query: "chicken")
        // 内置数据包含鸡胸肉
        XCTAssertFalse(results.isEmpty)
    }

    // MARK: - AI 方案引擎测试
    func testAIEngine_Underweight() {
        let profile = UserProfileModel(
            userID: "test", gender: .female, age: 22,
            height: 165, currentWeight: 45, targetWeight: 50,
            sportLevel: .light, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let plan = AIFastPlanEngine.shared.ruleBasedRecommendation(for: profile)
        XCTAssertEqual(plan.fastHour, 12, "偏瘦用户应推荐 12h 养生方案")
    }

    func testAIEngine_NormalBMI() {
        let profile = UserProfileModel(
            userID: "test", gender: .male, age: 28,
            height: 175, currentWeight: 70, targetWeight: 65,
            sportLevel: .moderate, workRestType: .regular,
            isGastroSensitive: false, isGirlPeriodSensitive: false
        )
        let plan = AIFastPlanEngine.shared.ruleBasedRecommendation(for: profile)
        XCTAssertEqual(plan.fastHour, 16, "标准体重应推荐 16:8")
    }
}
