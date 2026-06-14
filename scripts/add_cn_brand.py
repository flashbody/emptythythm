#!/usr/bin/env python3
"""P0: 中国高频成品菜 + P1: 品牌食品"""
import json

def item(id_,name,en,de,fr,cat,cal,pro,carb,fat,fib,gi,hs,fs,kw,src="CN_Standard"):
    return {"id":id_,"name":name,"nameEn":en,"nameDe":de,"nameFr":fr,"category":cat,
            "caloriesPer100g":float(cal),"protein":float(pro),"carb":float(carb),
            "fat":float(fat),"fiber":float(fib),"gi":gi,"healthScore":int(hs),
            "fastingScore":int(fs),"keywords":kw,"dataSource":src,"confidence":"verified"}

new_foods=[]

# ── P0: 中国高频成品菜（国标食物成分数据）────────────────────────────────────
cn_dishes=[
# 家常菜
("hongshao_rou","红烧肉","Red Braised Pork","Rotgeschmortes Schwein","Porc braisé rouge","fast_food",395,13,8,37,0,"medium",1,2,["红烧肉","braised pork","hongshao"]),
("tomato_egg","番茄炒鸡蛋","Tomato and Egg Stir-fry","Tomaten-Ei-Pfanne","Tomates oeufs sautés","fast_food",85,5.5,6,4.5,1,"low",4,6,["番茄炒蛋","tomato egg","西红柿炒鸡蛋"]),
("mapo_tofu","麻婆豆腐","Mapo Tofu","Mapo Tofu","Mapo tofu","fast_food",120,8,5,8,1,"low",3,5,["麻婆豆腐","mapo tofu"]),
("kung_pao","宫保鸡丁","Kung Pao Chicken","Kung Pao Hähnchen","Poulet kung pao","fast_food",185,16,8,10,1,"medium",3,5,["宫保鸡丁","kung pao chicken"]),
("sweet_sour_pork","糖醋里脊","Sweet and Sour Pork","Süß-Saures Schwein","Porc aigre-doux","fast_food",220,12,22,10,0.5,"high",2,3,["糖醋里脊","sweet sour pork"]),
("yu_xiang_pork","鱼香肉丝","Yu Xiang Pork","Yuxiang Schwein","Porc yuxiang","fast_food",175,14,10,9,1,"medium",2,4,["鱼香肉丝","yuxiang pork"]),
("di_san_xian","地三鲜","Di San Xian","Di San Xian","Di san xian","fast_food",130,3,15,7,2,"medium",3,5,["地三鲜","di san xian","土豆茄子"]),
("hui_guo_rou","回锅肉","Twice Cooked Pork","Zweimal gekochtes Schwein","Porc deux fois cuit","fast_food",310,14,5,26,0.5,"low",2,3,["回锅肉","twice cooked pork"]),
("qing_jiao_rou","青椒肉丝","Pork with Green Pepper","Schwein mit grüner Paprika","Porc poivron vert","fast_food",145,14,5,8,1,"low",3,5,["青椒肉丝","pork green pepper"]),
("dongpo_pork","东坡肉","Dongpo Pork","Dongpo Schwein","Porc Dongpo","fast_food",430,11,12,40,0,"medium",1,2,["东坡肉","dongpo pork"]),
("lion_head","狮子头","Lion's Head Meatball","Löwenkopf-Fleischbällchen","Boulette lion","fast_food",285,15,8,22,0.5,"medium",2,3,["狮子头","lion head meatball"]),
("braised_eggplant","红烧茄子","Braised Eggplant","Geschmorte Aubergine","Aubergine braisée","fast_food",95,2,10,5.5,2,"medium",3,5,["红烧茄子","braised eggplant"]),
("stir_cabbage","手撕包菜","Stir-fried Cabbage","Gebratener Kohl","Chou sauté","vegetable",65,1.5,7,3.5,2,"low",4,7,["手撕包菜","stir fried cabbage"]),
("garlic_spinach","蒜蓉菠菜","Garlic Spinach","Knoblauch Spinat","Épinards ail","vegetable",55,3,4,3,2,"very_low",5,9,["蒜蓉菠菜","garlic spinach"]),
("cold_cucumber","拍黄瓜","Smashed Cucumber Salad","Gurken Salat","Salade concombre","vegetable",30,0.8,4,1.5,0.5,"very_low",5,9,["拍黄瓜","smashed cucumber","凉拌黄瓜"]),
("cold_tofu","凉拌豆腐","Cold Tofu Salad","Kalter Tofu Salat","Tofu froid","vegetable",85,8,2,5,0.3,"very_low",5,8,["凉拌豆腐","cold tofu"]),
("egg_tofu","鸡蛋豆腐","Egg Tofu","Ei-Tofu","Tofu oeuf","fast_food",90,7,3,6,0.2,"very_low",4,7,["鸡蛋豆腐","egg tofu"]),
("steamed_egg","蒸水蛋","Steamed Egg Custard","Gedämpfter Eierstich","Flan oeuf vapeur","egg",75,7,1,4.5,0,"very_low",5,8,["蒸水蛋","steamed egg custard"]),
("scrambled_shrimp","虾仁炒蛋","Shrimp and Egg","Garnelen mit Ei","Crevettes oeufs","protein",145,16,1,8.5,0,"very_low",5,8,["虾仁炒蛋","shrimp egg"]),
("steamed_fish","清蒸鱼","Steamed Fish","Gedämpfter Fisch","Poisson vapeur","protein",105,18,1,3.5,0,"very_low",5,9,["清蒸鱼","steamed fish"]),
("braised_fish","红烧鱼","Braised Fish","Geschmorter Fisch","Poisson braisé","protein",155,18,6,7,0,"medium",3,6,["红烧鱼","braised fish"]),
("sour_fish","酸菜鱼","Sour Cabbage Fish","Sauerkraut Fisch","Poisson choucroute","fast_food",130,15,4,6,0.5,"low",3,5,["酸菜鱼","sour cabbage fish"]),
("boiled_fish","水煮鱼","Boiled Spicy Fish","Gekochter Würzfisch","Poisson bouilli épicé","fast_food",145,16,3,8,0.5,"low",2,4,["水煮鱼","boiled spicy fish"]),
("dry_pot_chicken","干锅鸡","Dry Pot Chicken","Trockentopf Hähnchen","Poulet pot sec","fast_food",215,18,8,13,1,"medium",2,4,["干锅鸡","dry pot chicken"]),
("kung_pao_shrimp","宫保虾仁","Kung Pao Shrimp","Kung Pao Garnelen","Crevettes kung pao","fast_food",155,18,6,7,0.5,"medium",4,6,["宫保虾仁","kung pao shrimp"]),
# 汤类
("egg_drop_soup","蛋花汤","Egg Drop Soup","Eierstich Suppe","Soupe oeuf","fast_food",35,3,3,1.5,0,"low",4,7,["蛋花汤","egg drop soup"]),
("hot_sour_soup","酸辣汤","Hot and Sour Soup","Heiß-Sauer Suppe","Soupe aigre piquante","fast_food",55,4,7,1.5,0.5,"low",3,5,["酸辣汤","hot sour soup"]),
("tomato_soup_cn","西红柿汤","Tomato Soup","Tomatensuppe","Soupe tomate","fast_food",30,1.2,5,0.8,0.8,"low",4,7,["西红柿汤","tomato soup"]),
("winter_melon_soup","冬瓜汤","Winter Melon Soup","Wachskürbis Suppe","Soupe courge","fast_food",20,0.8,3.5,0.3,0.5,"very_low",5,8,["冬瓜汤","winter melon soup"]),
("seaweed_soup","紫菜蛋花汤","Seaweed Egg Soup","Meeresalgen Suppe","Soupe algues oeuf","fast_food",30,2.5,3,1,0.3,"very_low",5,8,["紫菜蛋花汤","seaweed egg soup"]),
# 主食类
("fried_rice_egg","蛋炒饭","Egg Fried Rice","Eier Gebratener Reis","Riz frit oeuf","grain",185,6,28,6,0.5,"high",2,3,["蛋炒饭","egg fried rice"]),
("yangzhou_rice","扬州炒饭","Yangzhou Fried Rice","Yangzhou Gebratener Reis","Riz frit Yangzhou","grain",195,7,29,6.5,0.5,"high",2,3,["扬州炒饭","yangzhou fried rice"]),
("steamed_bun","馒头","Steamed Bun","Gedämpftes Brötchen","Pain vapeur","grain",223,7,46,1.2,1.5,"high",3,4,["馒头","steamed bun","mantou"]),
("flower_roll","花卷","Flower Roll","Blumenrolle","Rouleau fleur","grain",220,7,45,1,1.5,"high",3,4,["花卷","flower roll"]),
("scallion_pancake","葱油饼","Scallion Pancake","Frühlingszwiebel Pfannkuchen","Crêpe oignon","grain",310,7,40,14,1.5,"high",2,3,["葱油饼","scallion pancake"]),
("noodle_beef","牛肉面","Beef Noodle Soup","Rindfleisch Nudelsuppe","Soupe nouilles boeuf","fast_food",165,10,22,4,1,"high",3,4,["牛肉面","beef noodle"]),
("noodle_zhajiang","炸酱面","Zhajiang Noodles","Zhajiang Nudeln","Nouilles zhajiang","fast_food",220,10,32,7,1.5,"high",2,3,["炸酱面","zhajiang noodles"]),
("noodle_cold","凉面","Cold Noodles","Kalte Nudeln","Nouilles froides","fast_food",175,5,30,5,1,"high",2,3,["凉面","cold noodles"]),
("congee_plain","白粥","Plain Congee","Reisbrei","Congee","grain",25,0.8,5,0.1,0.1,"low",4,7,["白粥","plain congee","稀饭"]),
("congee_pork","皮蛋瘦肉粥","Century Egg Pork Congee","Jahrhundertei Schwein Congee","Congee oeuf centenaire","grain",65,4.5,9,1.5,0.2,"low",3,5,["皮蛋瘦肉粥","century egg congee"]),
# 小吃/早餐
("soy_milk","豆浆","Soy Milk","Sojamilch","Lait soja","beverage",54,3.3,6.3,1.8,0.6,"low",4,7,["豆浆","soy milk"]),
("fried_dough","油条","Fried Dough Stick","Gebratener Teigstab","Beignet chinois","snack",388,7.9,50,18,1,"high",1,1,["油条","fried dough stick","youtiao"]),
("rice_noodle_roll","肠粉","Rice Noodle Roll","Reismehlrolle","Rouleau riz","fast_food",110,3.5,18,3,0.5,"medium",3,4,["肠粉","rice noodle roll","cheung fun"]),
("turnip_cake","萝卜糕","Turnip Cake","Rettichkuchen","Gâteau navet","fast_food",130,2.5,22,4,1,"medium",3,4,["萝卜糕","turnip cake","lo bak go"]),
("egg_tart","蛋挞","Egg Tart","Eiertörtchen","Tartelette oeuf","dessert",265,5.5,28,15,0.5,"high",1,1,["蛋挞","egg tart","dan tat"]),
("wife_cake","老婆饼","Wife Cake","Ehefrauenkuchen","Gâteau épouse","dessert",385,5,65,13,1,"high",1,1,["老婆饼","wife cake"]),
("sesame_ball","煎堆/芝麻球","Sesame Ball","Sesamball","Boule sésame","dessert",320,4.5,48,13,2,"high",1,1,["芝麻球","sesame ball","jian dui"]),
# 火锅食材
("hot_pot_beef","火锅牛肉片","Hot Pot Beef Slices","Heißer Topf Rindfleisch","Fondue boeuf","protein",175,20,0,10,0,"very_low",3,5,["火锅牛肉","hot pot beef"]),
("hot_pot_lamb","火锅羊肉片","Hot Pot Lamb Slices","Heißer Topf Lamm","Fondue agneau","protein",185,18,0,12,0,"very_low",3,5,["火锅羊肉","hot pot lamb"]),
("fish_ball","鱼丸","Fish Ball","Fischbällchen","Boulette poisson","fast_food",95,9,8,3,0,"medium",3,5,["鱼丸","fish ball"]),
("beef_ball","牛肉丸","Beef Ball","Rindfleischbällchen","Boulette boeuf","fast_food",120,12,5,6,0,"medium",3,5,["牛肉丸","beef ball"]),
("tofu_skin","豆腐皮","Tofu Skin","Tofuhaut","Peau de tofu","protein",195,18,8,11,0.5,"low",4,7,["豆腐皮","tofu skin","yuba"]),
("enoki_hot_pot","金针菇(火锅)","Enoki Mushroom Hot Pot","Enoki Heißer Topf","Enoki fondue","vegetable",37,2.7,7.6,0.3,2.7,"very_low",5,9,["金针菇火锅","enoki hot pot"]),
# 外卖高频
("malatang","麻辣烫(综合)","Malatang Mixed","Malatang Gemischt","Malatang mixte","fast_food",145,8,15,6,2,"medium",2,3,["麻辣烫","malatang"]),
("chuanchuan","串串香","Chuanchuan Skewers","Chuanchuan Spieße","Brochettes chuanchuan","fast_food",165,9,12,9,1.5,"medium",2,3,["串串香","chuanchuan"]),
("sheng_jian","生煎包","Pan-fried Pork Bun","Gebratenes Schweinbrötchen","Baozi poêlé","fast_food",240,10,28,10,1,"high",2,3,["生煎包","pan fried pork bun"]),
("xiao_long_bao","小笼包","Xiaolongbao","Xiaolongbao","Xiaolongbao","fast_food",185,9,22,7,0.5,"high",3,4,["小笼包","xiaolongbao","soup dumpling"]),
("wonton_red_oil","红油抄手","Red Oil Wonton","Rotes Öl Wan Tan","Wonton huile rouge","fast_food",195,8,24,8,0.5,"high",2,3,["红油抄手","red oil wonton"]),
]
for d in cn_dishes:
    new_foods.append(item(*d))

# ── P1: 品牌食品（官方营养标签数据）────────────────────────────────────────
brand_foods=[
# 麦当劳
("mcdonalds_big_mac","麦当劳巨无霸","McDonald's Big Mac","McDonald's Big Mac","Big Mac McDonald's","fast_food",257,13,29,11,1.5,"high",1,1,["big mac","巨无霸","麦当劳"],"Brand_Official"),
("mcdonalds_fries_m","麦当劳薯条(中)","McDonald's Medium Fries","McDonald's Pommes M","Frites McDonald's M","fast_food",312,3.4,41,15,3.8,"high",1,0,["mcdonalds fries","麦当劳薯条"],"Brand_Official"),
("mcdonalds_mcchicken","麦当劳麦辣鸡腿堡","McDonald's McChicken","McDonald's McChicken","McChicken McDonald's","fast_food",395,19,42,17,2,"high",1,1,["mcchicken","麦辣鸡腿堡"],"Brand_Official"),
("mcdonalds_filet_o_fish","麦当劳麦香鱼","McDonald's Filet-O-Fish","McDonald's Filet-O-Fish","Filet-O-Fish McDonald's","fast_food",329,15,37,14,1.5,"high",1,1,["filet o fish","麦香鱼"],"Brand_Official"),
# KFC
("kfc_original_chicken","肯德基原味鸡","KFC Original Chicken","KFC Originalrezept Hähnchen","KFC Poulet original","fast_food",320,22,14,21,0.5,"high",1,1,["kfc original","肯德基原味鸡"],"Brand_Official"),
("kfc_zinger","肯德基辣鸡腿堡","KFC Zinger Burger","KFC Zinger Burger","KFC Zinger","fast_food",390,20,40,17,2,"high",1,1,["kfc zinger","辣鸡腿堡"],"Brand_Official"),
("kfc_egg_tart","肯德基蛋挞","KFC Egg Tart","KFC Eiertörtchen","KFC Tartelette","dessert",265,5.5,28,15,0.5,"high",1,1,["kfc egg tart","肯德基蛋挞"],"Brand_Official"),
# 星巴克
("starbucks_latte","星巴克拿铁(中杯)","Starbucks Latte Grande","Starbucks Latte Grande","Starbucks Latte Grande","beverage",190,10,19,7,0,"medium",2,3,["starbucks latte","星巴克拿铁"],"Brand_Official"),
("starbucks_americano","星巴克美式","Starbucks Americano","Starbucks Americano","Starbucks Americano","beverage",15,1,2,0,0,"very_low",4,8,["starbucks americano","星巴克美式"],"Brand_Official"),
("starbucks_frappuccino","星巴克星冰乐(中杯)","Starbucks Frappuccino Grande","Starbucks Frappuccino Grande","Starbucks Frappuccino Grande","beverage",240,4,43,6,0,"high",1,0,["starbucks frappuccino","星冰乐"],"Brand_Official"),
("starbucks_matcha_latte","星巴克抹茶拿铁","Starbucks Matcha Latte","Starbucks Matcha Latte","Starbucks Latte matcha","beverage",220,10,32,6,0,"medium",2,3,["starbucks matcha","星巴克抹茶"],"Brand_Official"),
# 可口可乐系列
("coca_cola_330","可口可乐(330ml)","Coca-Cola 330ml","Coca-Cola 330ml","Coca-Cola 330ml","beverage",140,0,35,0,0,"high",1,0,["coca cola","可口可乐","coke"],"Brand_Official"),
("coca_cola_zero","可口可乐零度","Coca-Cola Zero","Coca-Cola Zero","Coca-Cola Zero","beverage",1,0,0.1,0,0,"very_low",2,5,["coca cola zero","可口可乐零度","coke zero"],"Brand_Official"),
("sprite_330","雪碧(330ml)","Sprite 330ml","Sprite 330ml","Sprite 330ml","beverage",130,0,33,0,0,"high",1,0,["sprite","雪碧"],"Brand_Official"),
("fanta_orange","芬达橙味(330ml)","Fanta Orange 330ml","Fanta Orange 330ml","Fanta Orange 330ml","beverage",140,0,36,0,0,"high",1,0,["fanta","芬达"],"Brand_Official"),
# 运动/功能饮料
("red_bull","红牛(250ml)","Red Bull 250ml","Red Bull 250ml","Red Bull 250ml","beverage",113,0,28,0,0,"high",1,1,["red bull","红牛"],"Brand_Official"),
("monster_energy","魔爪能量(355ml)","Monster Energy 355ml","Monster Energy 355ml","Monster Energy 355ml","beverage",160,0,40,0,0,"high",1,1,["monster energy","魔爪"],"Brand_Official"),
("gatorade","佳得乐(591ml)","Gatorade 591ml","Gatorade 591ml","Gatorade 591ml","beverage",140,0,36,0,0,"medium",2,3,["gatorade","佳得乐"],"Brand_Official"),
# 零食品牌
("lays_original","乐事原味薯片(75g)","Lay's Original Chips 75g","Lay's Original Chips 75g","Lay's Chips original 75g","snack",400,5,55,20,3.5,"high",1,0,["lays chips","乐事薯片"],"Brand_Official"),
("oreo_original","奥利奥原味(100g)","Oreo Original 100g","Oreo Original 100g","Oreo original 100g","snack",472,5,67,20,2.5,"high",1,0,["oreo","奥利奥"],"Brand_Official"),
("snickers","士力架(50g)","Snickers 50g","Snickers 50g","Snickers 50g","snack",250,4,32,12,1,"high",1,0,["snickers","士力架"],"Brand_Official"),
("kitkat","奇巧巧克力(45g)","KitKat 45g","KitKat 45g","KitKat 45g","snack",218,2.7,28,11,0.7,"high",1,0,["kitkat","奇巧"],"Brand_Official"),
# 即食/方便食品
("instant_noodle_maruchan","日清合味道(85g)","Nissin Cup Noodles 85g","Nissin Cup Noodles 85g","Nissin Cup Noodles 85g","fast_food",370,8,52,14,2,"high",1,0,["nissin cup noodles","日清","合味道"],"Brand_Official"),
("instant_noodle_master","康师傅红烧牛肉面(100g)","Master Kong Braised Beef Noodle","Master Kong Nudeln","Nouilles Master Kong","fast_food",430,9,62,16,2,"high",1,0,["康师傅","master kong","红烧牛肉面"],"Brand_Official"),
# 酸奶品牌
("yoplait_strawberry","优诺草莓酸奶(100g)","Yoplait Strawberry Yogurt 100g","Yoplait Erdbeer Joghurt 100g","Yoplait yaourt fraise 100g","dairy",95,3.5,16,2,0,"medium",3,4,["yoplait","优诺","草莓酸奶"],"Brand_Official"),
("chobani_plain","乔巴尼希腊酸奶(100g)","Chobani Plain Greek Yogurt 100g","Chobani Griechischer Joghurt 100g","Chobani yaourt grec 100g","dairy",97,9,3.6,5,0,"low",5,8,["chobani","希腊酸奶"],"Brand_Official"),
# 蛋白棒/营养品
("quest_bar","Quest蛋白棒(60g)","Quest Protein Bar 60g","Quest Proteinriegel 60g","Quest barre protéinée 60g","protein",200,21,22,7,14,"low",4,7,["quest bar","蛋白棒","quest protein"],"Brand_Official"),
("rx_bar","RXBar蛋白棒(52g)","RXBAR Protein Bar 52g","RXBAR Proteinriegel 52g","RXBAR barre protéinée 52g","protein",210,12,23,9,5,"medium",4,6,["rxbar","rx bar","蛋白棒"],"Brand_Official"),
# 燕麦品牌
("quaker_oats","桂格燕麦片(40g)","Quaker Oats 40g","Quaker Haferflocken 40g","Quaker flocons avoine 40g","grain",150,5,27,2.5,4,"low",5,9,["quaker oats","桂格燕麦"],"Brand_Official"),
("uncle_tobys","Uncle Tobys燕麦(40g)","Uncle Tobys Oats 40g","Uncle Tobys Haferflocken 40g","Uncle Tobys flocons 40g","grain",152,5,27,2.8,4,"low",5,9,["uncle tobys","燕麦"],"Brand_Official"),
]
for d in brand_foods:
    new_foods.append(item(*d))

print(f"新增食物: {len(new_foods)} 条")

# 加载并合并
db_path="/Users/a39/Documents/AIProject/EmptyRhythm/EmptyRhythm/Resources/foods_database.json"
with open(db_path) as f: foods=json.load(f)
existing_ids={x["id"] for x in foods}

added=0
for food in new_foods:
    if food["id"] not in existing_ids:
        foods.append(food)
        existing_ids.add(food["id"])
        added+=1

print(f"实际新增: {added} 条（去重后）")
print(f"总条数: {len(foods)}")

with open(db_path,"w",encoding="utf-8") as f:
    json.dump(foods,f,ensure_ascii=False,separators=(",",":"))

import os
print(f"文件大小: {os.path.getsize(db_path)/1024/1024:.1f} MB")
