import Foundation
import UIKit

// MARK: - 食物模型
struct FoodItem: Codable {
    let id: String
    let name: String           // 中文名
    let nameEn: String         // 英文名
    let nameDe: String         // 德文名
    let nameFr: String         // 法文名
    let category: FoodCategory
    let caloriesPer100g: Double
    let protein: Double        // g/100g
    let carb: Double           // g/100g
    let fat: Double            // g/100g
    let fiber: Double          // g/100g
    let gi: GILevel
    let healthScore: Int       // 1-5
    let fastingScore: Int      // 0-10
    let keywords: [String]     // 搜索关键词

    var localizedName: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        switch lang {
        case "de": return nameDe.isEmpty ? nameEn : nameDe
        case "fr": return nameFr.isEmpty ? nameEn : nameFr
        case "zh": return name
        default:   return nameEn
        }
    }
}

// MARK: - 食物分类
enum FoodCategory: String, Codable, CaseIterable {
    case protein      = "protein"       // 优质蛋白
    case grain        = "grain"         // 粗粮主食
    case vegetable    = "vegetable"     // 蔬菜
    case fruit        = "fruit"         // 水果
    case dairy        = "dairy"         // 乳制品
    case nuts         = "nuts"          // 坚果
    case beverage     = "beverage"      // 饮品
    case snack        = "snack"         // 零食
    case processedMeat = "processed_meat" // 加工肉
    case redMeat      = "red_meat"      // 红肉
    case seafood      = "seafood"       // 海鲜
    case egg          = "egg"           // 蛋类
    case oil          = "oil"           // 油脂
    case condiment    = "condiment"     // 调味品
    case fastFood     = "fast_food"     // 快餐
    case dessert      = "dessert"       // 甜点

    var displayName: String { L("food.category.\(rawValue)") }

    var icon: String {
        switch self {
        case .protein:      return "🍗"
        case .grain:        return "🌾"
        case .vegetable:    return "🥦"
        case .fruit:        return "🍎"
        case .dairy:        return "🥛"
        case .nuts:         return "🥜"
        case .beverage:     return "☕️"
        case .snack:        return "🍿"
        case .processedMeat: return "🌭"
        case .redMeat:      return "🥩"
        case .seafood:      return "🦐"
        case .egg:          return "🥚"
        case .oil:          return "🫙"
        case .condiment:    return "🧂"
        case .fastFood:     return "🍔"
        case .dessert:      return "🍰"
        }
    }
}

// MARK: - GI 值分级
enum GILevel: String, Codable {
    case veryLow = "very_low"   // < 35
    case low = "low"            // 35-55
    case medium = "medium"      // 55-70
    case high = "high"          // > 70

    var displayName: String { L("food.gi.\(rawValue)") }
    var color: UIColor {
        switch self {
        case .veryLow: return AppColor.mainTint
        case .low:     return AppColor.mainTint
        case .medium:  return AppColor.warningOrange
        case .high:    return AppColor.danger
        }
    }
}

// MARK: - 食物库服务
final class FoodDatabaseService {

    static let shared = FoodDatabaseService()
    private init() {}

    private var _foods: [FoodItem]?

    var allFoods: [FoodItem] {
        if let cached = _foods { return cached }
        let loaded = loadFoods()
        _foods = loaded
        return loaded
    }

    // MARK: - 搜索
    func search(query: String) -> [FoodItem] {
        guard !query.isEmpty else { return Array(allFoods.prefix(50)) }
        let q = query.lowercased()
        return allFoods.filter { food in
            food.name.lowercased().contains(q) ||
            food.nameEn.lowercased().contains(q) ||
            food.nameDe.lowercased().contains(q) ||
            food.nameFr.lowercased().contains(q) ||
            food.keywords.contains { $0.lowercased().contains(q) }
        }
    }

    // MARK: - 按分类筛选
    func foods(in category: FoodCategory) -> [FoodItem] {
        allFoods.filter { $0.category == category }
    }

    // MARK: - 按 ID 查找
    func food(byID id: String) -> FoodItem? {
        allFoods.first { $0.id == id }
    }

    // MARK: - Vision 识别结果匹配（拍照识餐）
    func matchByVisionLabel(_ label: String, confidence: Float) -> [FoodItem] {
        let q = label.lowercased()
        var results = allFoods.filter { food in
            food.nameEn.lowercased().contains(q) ||
            food.keywords.contains { $0.lowercased().contains(q) }
        }
        // 按置信度排序，返回前 5 个候选
        results = Array(results.prefix(5))
        return results
    }

    // MARK: - 加载数据
    private func loadFoods() -> [FoodItem] {
        guard let url = Bundle.main.url(forResource: "foods_database", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foods = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            return FoodDatabaseService.builtinFoods()
        }
        return foods
    }

    // MARK: - 内置精简数据（Bundle 加载失败时的兜底）
    static func builtinFoods() -> [FoodItem] {
        return [
            FoodItem(id: "chicken_breast", name: "鸡胸肉(水煮)", nameEn: "Chicken Breast (boiled)",
                     nameDe: "Hähnchenbrust (gekocht)", nameFr: "Blanc de poulet (bouilli)",
                     category: .protein, caloriesPer100g: 118, protein: 23, carb: 0, fat: 2.6, fiber: 0,
                     gi: .veryLow, healthScore: 5, fastingScore: 10, keywords: ["chicken", "poulet", "hähnchen", "鸡"]),
            FoodItem(id: "egg_boiled", name: "鸡蛋(水煮)", nameEn: "Egg (boiled)",
                     nameDe: "Ei (gekocht)", nameFr: "Oeuf (dur)",
                     category: .egg, caloriesPer100g: 143, protein: 13.3, carb: 2.8, fat: 8.8, fiber: 0,
                     gi: .low, healthScore: 5, fastingScore: 9, keywords: ["egg", "oeuf", "ei", "蛋"]),
            FoodItem(id: "broccoli", name: "西兰花", nameEn: "Broccoli",
                     nameDe: "Brokkoli", nameFr: "Brocoli",
                     category: .vegetable, caloriesPer100g: 34, protein: 2.8, carb: 4.5, fat: 0.4, fiber: 1.6,
                     gi: .veryLow, healthScore: 5, fastingScore: 10, keywords: ["broccoli", "brokkoli", "西兰"]),
        ]
    }
}
