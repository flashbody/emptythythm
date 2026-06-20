import Foundation

// MARK: - Vision 标签 → 食物库映射器
struct VisionFoodMapper {

    private static let labelMap: [(pattern: String, foodIDs: [String])] = [
        // 水果（含 ImageNet 品种名）
        ("granny smith",    ["apple"]),
        ("red delicious",   ["apple"]),
        ("golden delicious",["apple"]),
        ("fuji",            ["apple"]),
        ("apple",           ["apple"]),
        ("pear",            ["pear"]),
        ("banana",          ["banana"]),
        ("orange",          ["orange"]),
        ("mandarin",        ["mandarin"]),
        ("tangerine",       ["mandarin"]),
        ("clementine",      ["mandarin"]),
        ("lemon",           ["lemon"]),
        ("lime",            ["lime"]),
        ("strawberry",      ["strawberry"]),
        ("blueberry",       ["blueberry"]),
        ("raspberry",       ["raspberry"]),
        ("blackberry",      ["blackberry"]),
        ("cherry",          ["cherry"]),
        ("grape",           ["grape_red", "grape_green"]),
        ("watermelon",      ["watermelon"]),
        ("cantaloupe",      ["cantaloupe"]),
        ("honeydew",        ["honeydew"]),
        ("mango",           ["mango"]),
        ("pineapple",       ["pineapple"]),
        ("papaya",          ["papaya"]),
        ("kiwi",            ["kiwi"]),
        ("peach",           ["peach"]),
        ("nectarine",       ["nectarine"]),
        ("plum",            ["plum"]),
        ("apricot",         ["apricot"]),
        ("pomegranate",     ["pomegranate"]),
        ("fig",             ["fig_fresh"]),
        ("coconut",         ["coconut_fresh"]),
        ("avocado",         ["avocado"]),
        ("durian",          ["durian"]),
        ("lychee",          ["lychee"]),
        ("dragon fruit",    ["dragon_fruit"]),
        ("pitaya",          ["dragon_fruit"]),
        ("jackfruit",       ["jackfruit"]),
        ("guava",           ["guava"]),
        ("passion fruit",   ["passion_fruit"]),
        ("persimmon",       ["persimmon"]),
        ("mulberry",        ["mulberry"]),
        ("cranberry",       ["cranberry"]),
        ("plantain",        ["plantain"]),
        ("kumquat",         ["kumquat"]),
        // 蔬菜
        ("broccoli",        ["broccoli"]),
        ("spinach",         ["spinach"]),
        ("kale",            ["kale"]),
        ("cucumber",        ["cucumber"]),
        ("tomato",          ["tomato", "cherry_tomato"]),
        ("lettuce",         ["lettuce"]),
        ("cabbage",         ["cabbage"]),
        ("carrot",          ["carrot"]),
        ("celery",          ["celery"]),
        ("bell pepper",     ["bell_pepper_red", "bell_pepper_green"]),
        ("red pepper",      ["bell_pepper_red"]),
        ("green pepper",    ["bell_pepper_green"]),
        ("yellow pepper",   ["bell_pepper_yellow"]),
        ("chili",           ["chili_red"]),
        ("asparagus",       ["asparagus"]),
        ("zucchini",        ["zucchini"]),
        ("courgette",       ["zucchini"]),
        ("eggplant",        ["eggplant"]),
        ("aubergine",       ["eggplant"]),
        ("onion",           ["onion"]),
        ("garlic",          ["garlic"]),
        ("mushroom",        ["mushroom_white", "mushroom_shiitake"]),
        ("cauliflower",     ["cauliflower"]),
        ("brussels",        ["brussels_sprout"]),
        ("beet",            ["beet"]),
        ("sweet potato",    ["sweet_potato"]),
        ("yam",             ["sweet_potato"]),
        ("potato",          ["potato"]),
        ("pumpkin",         ["pumpkin"]),
        ("squash",          ["butternut_squash"]),
        ("corn",            ["corn_fresh"]),
        ("artichoke",       ["artichoke"]),
        ("fennel",          ["fennel"]),
        ("radish",          ["radish"]),
        ("daikon",          ["daikon"]),
        ("leek",            ["leek"]),
        ("pea",             ["pea"]),
        ("green bean",      ["green_bean"]),
        ("edamame",         ["edamame"]),
        ("tofu",            ["tofu_firm"]),
        ("bok choy",        ["bok_choy"]),
        ("pak choi",        ["bok_choy"]),
        ("seaweed",         ["kelp", "nori"]),
        ("nori",            ["nori"]),
        ("kimchi",          ["kimchi"]),
        ("bamboo",          ["bamboo_shoot"]),
        ("lotus",           ["lotus_root"]),
        ("bitter melon",    ["bitter_melon"]),
        ("okra",            ["okra"]),
        // 蛋白质/肉类
        ("chicken",         ["chicken_breast", "chicken_thigh"]),
        ("turkey",          ["turkey_breast"]),
        ("duck",            ["duck_breast"]),
        ("beef",            ["beef_lean", "beef_sirloin"]),
        ("steak",           ["beef_sirloin"]),
        ("pork",            ["pork_tenderloin"]),
        ("lamb",            ["lamb_leg"]),
        ("rabbit",          ["rabbit"]),
        ("salmon",          ["salmon"]),
        ("tuna",            ["tuna_fresh"]),
        ("cod",             ["cod"]),
        ("tilapia",         ["tilapia"]),
        ("mackerel",        ["mackerel"]),
        ("sardine",         ["sardine"]),
        ("shrimp",          ["shrimp"]),
        ("prawn",           ["shrimp"]),
        ("crab",            ["crab"]),
        ("lobster",         ["lobster"]),
        ("oyster",          ["oyster"]),
        ("squid",           ["squid"]),
        ("octopus",         ["octopus"]),
        ("mussel",          ["mussel"]),
        ("clam",            ["clam"]),
        ("scallop",         ["scallop"]),
        ("shellfish",       ["shrimp", "scallop", "clam", "mussel"]),
        ("shellfish_prepared", ["shrimp", "scallop", "clam"]),
        ("seafood",         ["shrimp", "salmon", "scallop"]),
        ("crustacean",      ["shrimp", "lobster", "crab"]),
        ("egg",             ["egg_boiled", "egg_fried"]),
        ("omelette",        ["egg_scrambled"]),
        // 主食
        ("rice",            ["white_rice", "brown_rice"]),
        ("noodle",          ["pasta_white_cooked", "noodle_rice"]),
        ("pasta",           ["pasta_white_cooked", "pasta_bolognese", "pasta_carbonara"]),
        ("spaghetti",       ["spaghetti_cooked", "pasta_bolognese"]),
        ("meatball",        ["beef_mince", "lion_head"]),
        ("bolognese",       ["pasta_bolognese"]),
        ("carbonara",       ["pasta_carbonara"]),
        ("bread",           ["bread_whole_wheat", "bread_white"]),
        ("toast",           ["bread_white"]),
        ("oat",             ["oats_rolled"]),
        ("porridge",        ["oatmeal"]),
        ("quinoa",          ["quinoa"]),
        ("tortilla",        ["tortilla_corn"]),
        ("dumpling",        ["dumpling_steamed"]),
        ("sushi",           ["sushi_salmon"]),
        ("ramen",           ["ramen_tonkotsu"]),
        ("congee",          ["congee_plain"]),
        ("fried rice",      ["fried_rice_egg"]),
        ("lentil",          ["lentils"]),
        ("chickpea",        ["chickpeas"]),
        // 乳制品
        ("milk",            ["milk_whole"]),
        ("yogurt",          ["yogurt_plain", "yogurt_greek"]),
        ("cheese",          ["cheese_cheddar"]),
        ("butter",          ["butter"]),
        ("ice cream",       ["ice_cream_vanilla"]),
        // 坚果
        ("almond",          ["almond"]),
        ("walnut",          ["walnut"]),
        ("cashew",          ["cashew"]),
        ("peanut",          ["peanut"]),
        ("pistachio",       ["pistachio"]),
        ("hazelnut",        ["hazelnut"]),
        ("nut",             ["almond", "walnut"]),
        // 饮品
        ("coffee",          ["black_coffee"]),
        ("espresso",        ["espresso"]),
        ("tea",             ["green_tea", "black_tea"]),
        ("green tea",       ["green_tea"]),
        ("matcha",          ["matcha"]),
        ("orange juice",    ["orange_juice"]),
        ("apple juice",     ["apple_juice"]),
        ("tomato juice",    ["tomato_juice"]),
        ("smoothie",        ["smoothie_green"]),
        // 快餐
        ("burger",          ["burger_beef"]),
        ("hamburger",       ["burger_beef"]),
        ("pizza",           ["pizza_margherita"]),
        ("hot dog",         ["hot_dog"]),
        ("french fries",    ["french_fries"]),
        ("fried chicken",   ["fried_chicken"]),
        ("sandwich",        ["baguette_sandwich"]),
        ("taco",            ["taco"]),
        ("salad",           ["caesar_salad"]),
        ("soup",            ["tomato_soup", "chicken_noodle_soup", "miso_soup", "egg_drop_soup"]),
        ("ramen",           ["ramen_tonkotsu", "ramen_miso", "instant_noodle_maruchan"]),
        ("instant noodle",  ["instant_noodle_maruchan", "instant_noodle_master"]),
        ("instant_noodle",  ["instant_noodle_maruchan", "instant_noodle_master"]),
        ("cup noodle",      ["instant_noodle_maruchan"]),
        ("cup_noodle",      ["instant_noodle_maruchan"]),
        ("curry",           ["green_curry"]),
        ("pad thai",        ["pad_thai"]),
        // 甜点
        ("cake",            ["cake_chocolate"]),
        ("cheesecake",      ["cake_cheesecake"]),
        ("baked goods",     ["croissant", "bread_white"]),
        ("baked_goods",     ["croissant", "bread_white"]),
        ("cookie",          ["cookie_chocolate_chip"]),
        ("chocolate",       ["chocolate_dark"]),
        ("dessert",         ["cake_chocolate", "ice_cream_vanilla"]),
        ("croissant",       ["croissant"]),
        ("waffle",          ["waffle"]),
        ("pancake",         ["pancake"]),
        ("chips",           ["chips_potato"]),
        ("popcorn",         ["popcorn_plain"]),
    ]

    // MARK: - 单标签匹配
    static func match(label: String, confidence: Float) -> [FoodItem] {
        let lowerLabel = label.lowercased()
        var results: [FoodItem] = []
        for (pattern, foodIDs) in labelMap {
            guard lowerLabel.contains(pattern) || pattern.contains(lowerLabel) else { continue }
            for foodID in foodIDs {
                let food = FoodDatabaseService.shared.food(byID: foodID + "_raw")
                        ?? FoodDatabaseService.shared.food(byID: foodID + "_boiled")
                        ?? FoodDatabaseService.shared.food(byID: foodID)
                if let food = food, !results.contains(where: { $0.id == food.id }) {
                    results.append(food)
                }
            }
            if results.count >= 3 { break }
        }
        #if DEBUG
        if !results.isEmpty {
            print("[VisionMapper] \(label)(\(String(format: "%.0f", confidence*100))%) → \(results.map { $0.localizedName })")
        }
        #endif
        return results
    }

    // MARK: - 批量匹配（按置信度排序，具体标签优先）
    static func matchMultiple(observations: [(label: String, confidence: Float)]) -> [FoodItem] {
        // 过滤掉泛类标签（太宽泛会误导）
        let genericLabels: Set<String> = [
            "food", "fruit", "vegetable", "produce", "plant",
            "natural object", "organism", "dish", "meal",
            "ingredient", "cuisine", "drink", "beverage",
            "berry", "citrus", "tropical fruit", "stone fruit",
            "document", "screenshot", "chart", "diagram", "text",
            "paper", "image", "photo", "picture",
            "people", "person", "adult", "human", "face",
            "indoor", "outdoor", "nature", "sky", "background",
            "utensil", "tableware", "bowl", "plate", "cup",
            "cutlery", "fork", "knife", "spoon", "chopstick",
            "drinking_glass", "glass", "liquid", "drink",
            "container", "carton", "box", "package", "packaging",
            "structure", "wood", "wood_processed", "furniture",
            "seasonings", "condiment", "sauce", "spice",
            "surface", "floor", "wall", "table", "counter",
            "cutting board", "chopping board"
        ]

        let filtered = observations.filter { obs in
            let lower = obs.label.lowercased()
            guard obs.confidence > 0.05 else { return false }
            // 精确匹配泛类标签（不用 contains，避免 raspberry 被 berry 误杀）
            return !genericLabels.contains(lower)
        }

        // 按置信度降序，优先处理高置信度的具体标签
        let sorted = filtered.sorted { $0.confidence > $1.confidence }

        var results: [FoodItem] = []
        for obs in sorted {
            for m in match(label: obs.label, confidence: obs.confidence) {
                if !results.contains(where: { $0.id == m.id }) { results.append(m) }
            }
            if results.count >= 3 { break }
        }
        return results
    }
}
