import Foundation

// MARK: - Vision 标签 → 食物库映射器
// Vision VNClassifyImageRequest 返回 ImageNet 标签，此映射表将其转换为食物库 ID
struct VisionFoodMapper {

    // MARK: - 标签映射表（Vision 标签 → 食物库 ID 列表）
    // key: Vision 返回的 identifier（小写，支持部分匹配）
    // value: 食物库中对应的 food_id 前缀列表
    private static let labelMap: [(pattern: String, foodIDs: [String])] = [

        // ── 水果 ──────────────────────────────────────────────────────────────
        ("apple",           ["apple"]),
        ("granny smith",    ["apple"]),
        ("red delicious",   ["apple"]),
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

        // ── 蔬菜 ──────────────────────────────────────────────────────────────
        ("broccoli",        ["broccoli"]),
        ("spinach",         ["spinach"]),
        ("kale",            ["kale"]),
        ("cucumber",        ["cucumber"]),
        ("tomato",          ["tomato", "cherry_tomato"]),
        ("lettuce",         ["lettuce"]),
        ("cabbage",         ["cabbage"]),
        ("carrot",          ["carrot"]),
        ("celery",          ["celery"]),
        ("bell pepper",     ["bell_pepper_red", "bell_pepper_green", "bell_pepper_yellow"]),
        ("pepper",          ["bell_pepper_red", "chili_red"]),
        ("asparagus",       ["asparagus"]),
        ("zucchini",        ["zucchini"]),
        ("courgette",       ["zucchini"]),
        ("eggplant",        ["eggplant"]),
        ("aubergine",       ["eggplant"]),
        ("onion",           ["onion"]),
        ("garlic",          ["garlic"]),
        ("mushroom",        ["mushroom_white", "mushroom_shiitake"]),
        ("cauliflower",     ["cauliflower"]),
        ("brussels sprout", ["brussels_sprout"]),
        ("beet",            ["beet"]),
        ("sweet potato",    ["sweet_potato"]),
        ("potato",          ["potato"]),
        ("pumpkin",         ["pumpkin"]),
        ("squash",          ["butternut_squash", "pumpkin"]),
        ("corn",            ["corn_fresh", "corn_kernel"]),
        ("artichoke",       ["artichoke"]),
        ("fennel",          ["fennel"]),
        ("radish",          ["radish", "daikon"]),
        ("leek",            ["leek"]),
        ("pea",             ["pea", "snap_pea"]),
        ("green bean",      ["green_bean"]),
        ("edamame",         ["edamame"]),
        ("tofu",            ["tofu_firm", "tofu_silken"]),
        ("bok choy",        ["bok_choy"]),
        ("pak choi",        ["bok_choy"]),
        ("seaweed",         ["kelp", "nori", "wakame"]),
        ("nori",            ["nori"]),
        ("kimchi",          ["kimchi"]),
        ("bamboo",          ["bamboo_shoot"]),
        ("lotus root",      ["lotus_root"]),
        ("bitter melon",    ["bitter_melon"]),
        ("okra",            ["okra"]),

        // ── 蛋白质/肉类 ───────────────────────────────────────────────────────
        ("chicken",         ["chicken_breast", "chicken_thigh"]),
        ("turkey",          ["turkey_breast"]),
        ("duck",            ["duck_breast"]),
        ("beef",            ["beef_lean", "beef_sirloin"]),
        ("steak",           ["beef_sirloin", "beef_ribeye"]),
        ("pork",            ["pork_tenderloin", "pork_loin"]),
        ("lamb",            ["lamb_leg"]),
        ("rabbit",          ["rabbit"]),
        ("salmon",          ["salmon"]),
        ("tuna",            ["tuna_fresh", "tuna_canned"]),
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
        ("fish",            ["cod", "salmon", "tilapia"]),
        ("seafood",         ["shrimp", "crab", "scallop"]),

        // ── 蛋类 ──────────────────────────────────────────────────────────────
        ("egg",             ["egg_boiled", "egg_fried", "egg_scrambled"]),
        ("boiled egg",      ["egg_boiled"]),
        ("fried egg",       ["egg_fried"]),
        ("omelette",        ["egg_scrambled"]),

        // ── 主食/谷物 ─────────────────────────────────────────────────────────
        ("rice",            ["white_rice", "brown_rice"]),
        ("brown rice",      ["brown_rice"]),
        ("noodle",          ["pasta_white", "noodle_rice"]),
        ("pasta",           ["pasta_white", "pasta_whole_wheat"]),
        ("spaghetti",       ["pasta_white"]),
        ("bread",           ["bread_whole_wheat", "bread_white"]),
        ("toast",           ["bread_white", "bread_whole_wheat"]),
        ("bagel",           ["bagel_cream_cheese"]),
        ("oat",             ["oats_rolled", "oatmeal"]),
        ("porridge",        ["oatmeal", "congee_plain"]),
        ("quinoa",          ["quinoa"]),
        ("corn tortilla",   ["tortilla_corn"]),
        ("tortilla",        ["tortilla_corn"]),
        ("dumpling",        ["dumpling_steamed", "dumpling_fried"]),
        ("sushi",           ["sushi_salmon", "sushi_tuna"]),
        ("ramen",           ["ramen_tonkotsu", "ramen_miso"]),
        ("congee",          ["congee_plain"]),
        ("fried rice",      ["fried_rice_egg"]),
        ("lentil",          ["lentils"]),
        ("chickpea",        ["chickpeas"]),
        ("bean",            ["black_beans", "kidney_beans"]),

        // ── 乳制品 ────────────────────────────────────────────────────────────
        ("milk",            ["milk_whole", "milk_skim"]),
        ("yogurt",          ["yogurt_plain", "yogurt_greek"]),
        ("cheese",          ["cheese_cheddar", "cheese_mozzarella"]),
        ("butter",          ["butter"]),
        ("cream",           ["cream_heavy"]),
        ("ice cream",       ["ice_cream_vanilla"]),

        // ── 坚果/种子 ─────────────────────────────────────────────────────────
        ("almond",          ["almond"]),
        ("walnut",          ["walnut"]),
        ("cashew",          ["cashew"]),
        ("peanut",          ["peanut"]),
        ("pistachio",       ["pistachio"]),
        ("hazelnut",        ["hazelnut"]),
        ("nut",             ["almond", "walnut", "cashew"]),
        ("seed",            ["chia_seed", "sunflower_seed"]),

        // ── 饮品 ──────────────────────────────────────────────────────────────
        ("coffee",          ["black_coffee", "latte", "americano"]),
        ("espresso",        ["espresso"]),
        ("tea",             ["green_tea", "black_tea"]),
        ("green tea",       ["green_tea"]),
        ("matcha",          ["matcha"]),
        ("juice",           ["orange_juice", "apple_juice"]),
        ("smoothie",        ["smoothie_green"]),
        ("milk tea",        ["milk_tea_full", "milk_tea_half"]),

        // ── 快餐/料理 ─────────────────────────────────────────────────────────
        ("burger",          ["burger_beef", "burger_chicken"]),
        ("hamburger",       ["burger_beef"]),
        ("pizza",           ["pizza_margherita", "pizza_pepperoni"]),
        ("hot dog",         ["hot_dog"]),
        ("french fries",    ["french_fries"]),
        ("fried chicken",   ["fried_chicken", "kfc_original_chicken"]),
        ("sandwich",        ["baguette_sandwich"]),
        ("taco",            ["taco"]),
        ("burrito",         ["burrito"]),
        ("salad",           ["caesar_salad", "greek_salad", "cobb_salad"]),
        ("soup",            ["tomato_soup", "chicken_noodle_soup", "miso_soup"]),
        ("stir fry",        ["vegetable_stir_fry", "beef_stir_fry"]),
        ("curry",           ["green_curry", "chicken_tikka_masala"]),
        ("pad thai",        ["pad_thai"]),
        ("pho",             ["pho"]),
        ("bibimbap",        ["bibimbap"]),

        // ── 甜点/零食 ─────────────────────────────────────────────────────────
        ("cake",            ["cake_chocolate", "cake_cheesecake"]),
        ("cookie",          ["cookie_chocolate_chip", "cookie_oatmeal"]),
        ("chocolate",       ["chocolate_dark", "chocolate_milk"]),
        ("donut",           ["donut"]),
        ("croissant",       ["croissant"]),
        ("waffle",          ["waffle"]),
        ("pancake",         ["pancake"]),
        ("chips",           ["chips_potato", "chips_corn"]),
        ("popcorn",         ["popcorn_butter", "popcorn_plain"]),
        ("candy",           ["candy_gummy", "candy_hard"]),
        ("mochi",           ["mochi"]),
        ("egg tart",        ["egg_tart"]),
    ]

    // MARK: - 主匹配方法
    static func match(label: String, confidence: Float) -> [FoodItem] {
        let lowerLabel = label.lowercased()
        var results: [FoodItem] = []

        for (pattern, foodIDs) in labelMap {
            if lowerLabel.contains(pattern) || pattern.contains(lowerLabel) {
                for foodID in foodIDs {
                    // 优先匹配基础食物（不含烹饪变体）
                    if let food = FoodDatabaseService.shared.food(byID: foodID + "_raw") ??
                                  FoodDatabaseService.shared.food(byID: foodID + "_boiled") ??
                                  FoodDatabaseService.shared.food(byID: foodID) {
                        if !results.contains(where: { $0.id == food.id }) {
                            results.append(food)
                        }
                    }
                }
                if results.count >= 3 { break }
            }
        }

        return results
    }
}
