#!/usr/bin/env python3
"""
USDA FoodData Central 数据拉取脚本
用真实官方数据替换基础食物的营养数据
API: https://api.nal.usda.gov/fdc/v1/
"""
import json, time, urllib.request, urllib.parse

API_KEY = "DEMO_KEY"  # 免费，每小时 30 次，每天 1000 次
BASE_URL = "https://api.nal.usda.gov/fdc/v1"

# 基础食物 → USDA 搜索词映射
# 格式: (本地food_id前缀, USDA搜索词, 优选数据类型)
FOOD_QUERIES = [
    # 蛋白质类
    ("chicken_breast", "chicken breast raw", "SR Legacy"),
    ("chicken_thigh",  "chicken thigh raw",  "SR Legacy"),
    ("turkey_breast",  "turkey breast raw",  "SR Legacy"),
    ("duck_breast",    "duck breast raw",    "SR Legacy"),
    ("beef_lean",      "beef ground lean raw","SR Legacy"),
    ("beef_sirloin",   "beef sirloin raw",   "SR Legacy"),
    ("beef_mince",     "beef ground 90% lean","SR Legacy"),
    ("pork_tenderloin","pork tenderloin raw", "SR Legacy"),
    ("pork_loin",      "pork loin raw",      "SR Legacy"),
    ("lamb_leg",       "lamb leg raw",       "SR Legacy"),
    ("rabbit",         "rabbit raw",         "SR Legacy"),
    ("venison",        "venison raw",        "SR Legacy"),
    ("shrimp",         "shrimp raw",         "SR Legacy"),
    ("salmon",         "salmon atlantic raw","SR Legacy"),
    ("tuna_canned",    "tuna canned water",  "SR Legacy"),
    ("tuna_fresh",     "tuna bluefin raw",   "SR Legacy"),
    ("cod",            "cod atlantic raw",   "SR Legacy"),
    ("tilapia",        "tilapia raw",        "SR Legacy"),
    ("mackerel",       "mackerel raw",       "SR Legacy"),
    ("sardine",        "sardines canned",    "SR Legacy"),
    ("herring",        "herring raw",        "SR Legacy"),
    ("sea_bass",       "sea bass raw",       "SR Legacy"),
    ("trout",          "trout raw",          "SR Legacy"),
    ("halibut",        "halibut raw",        "SR Legacy"),
    ("scallop",        "scallops raw",       "SR Legacy"),
    ("crab",           "crab raw",           "SR Legacy"),
    ("lobster",        "lobster raw",        "SR Legacy"),
    ("oyster",         "oysters raw",        "SR Legacy"),
    ("squid",          "squid raw",          "SR Legacy"),
    ("mussel",         "mussels raw",        "SR Legacy"),
    ("clam",           "clams raw",          "SR Legacy"),
    ("octopus",        "octopus raw",        "SR Legacy"),
    # 蛋类
    ("egg_boiled",     "egg hard boiled",    "SR Legacy"),
    ("egg_white",      "egg white raw",      "SR Legacy"),
    ("egg_yolk",       "egg yolk raw",       "SR Legacy"),
    # 蔬菜
    ("broccoli",       "broccoli raw",       "SR Legacy"),
    ("spinach",        "spinach raw",        "SR Legacy"),
    ("kale",           "kale raw",           "SR Legacy"),
    ("cucumber",       "cucumber raw",       "SR Legacy"),
    ("tomato",         "tomato raw",         "SR Legacy"),
    ("lettuce",        "lettuce romaine raw","SR Legacy"),
    ("cabbage",        "cabbage raw",        "SR Legacy"),
    ("carrot",         "carrots raw",        "SR Legacy"),
    ("celery",         "celery raw",         "SR Legacy"),
    ("bell_pepper_red","peppers red raw",    "SR Legacy"),
    ("asparagus",      "asparagus raw",      "SR Legacy"),
    ("zucchini",       "zucchini raw",       "SR Legacy"),
    ("eggplant",       "eggplant raw",       "SR Legacy"),
    ("onion",          "onions raw",         "SR Legacy"),
    ("garlic",         "garlic raw",         "SR Legacy"),
    ("mushroom_white", "mushrooms raw",      "SR Legacy"),
    ("avocado",        "avocados raw",       "SR Legacy"),
    ("pea",            "peas green raw",     "SR Legacy"),
    ("green_bean",     "beans green raw",    "SR Legacy"),
    ("edamame",        "edamame frozen",     "SR Legacy"),
    ("tofu_firm",      "tofu firm",          "SR Legacy"),
    ("cauliflower",    "cauliflower raw",    "SR Legacy"),
    ("brussels_sprout","brussels sprouts raw","SR Legacy"),
    ("beet",           "beets raw",          "SR Legacy"),
    ("sweet_potato",   "sweet potato raw",   "SR Legacy"),
    ("potato",         "potato raw",         "SR Legacy"),
    # 主食
    ("brown_rice",     "rice brown cooked",  "SR Legacy"),
    ("white_rice",     "rice white cooked",  "SR Legacy"),
    ("quinoa",         "quinoa cooked",      "SR Legacy"),
    ("oats_rolled",    "oats rolled dry",    "SR Legacy"),
    ("oatmeal",        "oatmeal cooked",     "SR Legacy"),
    ("corn_fresh",     "corn sweet raw",     "SR Legacy"),
    ("bread_whole_wheat","bread whole wheat","SR Legacy"),
    ("bread_white",    "bread white",        "SR Legacy"),
    ("pasta_white",    "pasta cooked",       "SR Legacy"),
    ("lentils",        "lentils cooked",     "SR Legacy"),
    ("chickpeas",      "chickpeas cooked",   "SR Legacy"),
    ("black_beans",    "beans black cooked", "SR Legacy"),
    # 水果
    ("apple",          "apples raw",         "SR Legacy"),
    ("banana",         "bananas raw",        "SR Legacy"),
    ("orange",         "oranges raw",        "SR Legacy"),
    ("strawberry",     "strawberries raw",   "SR Legacy"),
    ("blueberry",      "blueberries raw",    "SR Legacy"),
    ("grape_red",      "grapes red raw",     "SR Legacy"),
    ("watermelon",     "watermelon raw",     "SR Legacy"),
    ("mango",          "mangos raw",         "SR Legacy"),
    ("kiwi",           "kiwifruit raw",      "SR Legacy"),
    ("peach",          "peaches raw",        "SR Legacy"),
    # 乳制品
    ("milk_whole",     "milk whole",         "SR Legacy"),
    ("milk_skim",      "milk nonfat",        "SR Legacy"),
    ("yogurt_plain",   "yogurt plain whole", "SR Legacy"),
    ("yogurt_greek",   "yogurt greek plain", "SR Legacy"),
    ("cheese_cheddar", "cheese cheddar",     "SR Legacy"),
    ("cheese_mozzarella","cheese mozzarella","SR Legacy"),
    ("butter",         "butter unsalted",    "SR Legacy"),
    # 坚果
    ("almond",         "almonds",            "SR Legacy"),
    ("walnut",         "walnuts",            "SR Legacy"),
    ("cashew",         "cashew nuts",        "SR Legacy"),
    ("peanut",         "peanuts raw",        "SR Legacy"),
    ("chia_seed",      "chia seeds",         "SR Legacy"),
    ("flaxseed",       "flaxseed",           "SR Legacy"),
    # 油脂
    ("olive_oil",      "olive oil",          "SR Legacy"),
    ("coconut_oil",    "coconut oil",        "SR Legacy"),
]

def fetch_usda(query, data_type="SR Legacy"):
    """从 USDA 搜索并返回最匹配的营养数据"""
    params = urllib.parse.urlencode({
        "query": query,
        "api_key": API_KEY,
        "pageSize": 5,
        "dataType": data_type,
    })
    url = f"{BASE_URL}/foods/search?{params}"
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            data = json.loads(resp.read())
        foods = data.get("foods", [])
        if not foods:
            # fallback: 不限 dataType
            params2 = urllib.parse.urlencode({"query": query, "api_key": API_KEY, "pageSize": 3})
            with urllib.request.urlopen(f"{BASE_URL}/foods/search?{params2}", timeout=10) as resp:
                data = json.loads(resp.read())
            foods = data.get("foods", [])
        return foods[0] if foods else None
    except Exception as e:
        print(f"  ERROR: {e}")
        return None

def extract_nutrients(food_data):
    """提取标准营养素"""
    if not food_data:
        return None
    nuts = {}
    for n in food_data.get("foodNutrients", []):
        name = n.get("nutrientName", "")
        val = n.get("value", 0)
        if "Energy" in name and "kJ" not in name:
            nuts["cal"] = round(float(val), 1)
        elif name == "Protein":
            nuts["protein"] = round(float(val), 1)
        elif "Carbohydrate" in name and "fiber" not in name.lower():
            nuts["carb"] = round(float(val), 1)
        elif "Total lipid" in name or name == "Fat":
            nuts["fat"] = round(float(val), 1)
        elif "Fiber" in name:
            nuts["fiber"] = round(float(val), 1)
    # 确保所有字段存在
    for k in ["cal","protein","carb","fat","fiber"]:
        nuts.setdefault(k, 0.0)
    return nuts

def main():
    print(f"开始从 USDA 拉取 {len(FOOD_QUERIES)} 种基础食物数据...\n")

    # 加载现有数据库
    db_path = "/Users/a39/Documents/AIProject/EmptyRhythm/EmptyRhythm/Resources/foods_database.json"
    with open(db_path) as f:
        foods = json.load(f)

    # 建立 id → index 索引
    id_index = {food["id"]: i for i, food in enumerate(foods)}

    results = {}
    success = 0
    fail = 0

    for food_id_prefix, query, data_type in FOOD_QUERIES:
        print(f"查询: {food_id_prefix} → '{query}'", end=" ... ")
        food_data = fetch_usda(query, data_type)
        nutrients = extract_nutrients(food_data)

        if nutrients and nutrients["cal"] > 0:
            results[food_id_prefix] = {
                "nutrients": nutrients,
                "usda_desc": food_data.get("description", ""),
                "fdc_id": food_data.get("fdcId", ""),
            }
            print(f"✓ {nutrients['cal']}kcal P{nutrients['protein']}g C{nutrients['carb']}g F{nutrients['fat']}g")
            success += 1
        else:
            print("✗ 未找到")
            fail += 1

        time.sleep(0.15)  # 避免超速限制

    print(f"\n拉取完成: 成功 {success}, 失败 {fail}")

    # 更新数据库中匹配的食物
    updated = 0
    for food_id_prefix, data in results.items():
        nuts = data["nutrients"]
        for food_id, idx in id_index.items():
            # 匹配所有以该前缀开头的食物（基础 + 变体）
            if food_id == food_id_prefix or food_id.startswith(food_id_prefix + "_"):
                food = foods[idx]
                # 更新基础营养数据
                old_cal = food["caloriesPer100g"]
                food["caloriesPer100g"] = nuts["cal"]
                food["protein"] = nuts["protein"]
                food["carb"] = nuts["carb"]
                food["fat"] = nuts["fat"]
                food["fiber"] = nuts["fiber"]
                # 添加数据来源标签
                food["dataSource"] = "USDA"
                food["fdcId"] = str(data["fdc_id"])
                food["confidence"] = "verified"  # Q3-B: 置信度标签
                updated += 1

    # 给未更新的食物加置信度标签
    for food in foods:
        if "confidence" not in food:
            food["confidence"] = "estimated"  # Q3-B: 估算数据
            food["dataSource"] = "estimated"

    print(f"更新了 {updated} 条食物数据（基础 + 变体）")

    # 保存
    with open(db_path, "w", encoding="utf-8") as f:
        json.dump(foods, f, ensure_ascii=False, separators=(",", ":"))

    size_mb = len(json.dumps(foods, ensure_ascii=False)) / 1024 / 1024
    print(f"数据库已更新: {len(foods)} 条, {size_mb:.1f} MB")
    print(f"已保存到: {db_path}")

if __name__ == "__main__":
    main()
