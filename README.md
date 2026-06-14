# EmptyRhythm — 空律

> 间歇性断食计时器 · iOS App · Swift + UIKit

## 产品简介

**空律（EmptyRhythm）** 是一款智能间歇性断食管理工具，核心解决断食计时混乱、遗忘进食窗口、无法长效追踪断食成果等痛点。

- **平台**：iOS 18.1+（iPhone-only）
- **定价**：买断制 $3.99
- **语言**：英语 / 德语 / 法语
- **目标市场**：美国 / 英国 / 澳大利亚 / 德国 / 法国

## 核心功能

| 功能 | 说明 |
|---|---|
| 断食计时器 | 环形进度 + 后台保活 + 系统时间校准 |
| 断食方案库 | 6种预设（12:12 ~ 20:4）+ AI 个性化推荐 |
| 食物库 | 14,999 条食物数据（中/英/德/法四语） |
| 饮食记录 | 分餐次记录 + 热量统计 + 宏量营养素 |
| 拍照识餐 | Vision 识别 → 5个候选确认 |
| 体重追踪 | 折线图 + AI 周期预测 |
| AI 助手 | 规则引擎 + Foundation Models（iOS 18.1+） |
| HealthKit | 步数/心率/卡路里同步 + 运动预警 |
| 小组件 | WidgetKit 环形进度（small/medium） |
| 设置 | 通知/AI/外观/隐私/IAP 完整配置 |

## 技术栈

- **语言**：Swift 5.10
- **UI**：UIKit（全程，非 SwiftUI）
- **数据**：CoreData + iCloud（NSPersistentCloudKitContainer）
- **AI**：Apple Foundation Models + 规则引擎降级
- **IAP**：StoreKit2 买断制
- **构建**：xcodegen 2.45.3

## 项目结构

```
EmptyRhythm/
├── project.yml                    # xcodegen 配置
├── EmptyRhythm.xcodeproj/
└── EmptyRhythm/
    ├── App/                       # AppDelegate / SceneDelegate / MainTabBarController
    ├── Core/
    │   ├── Extensions/            # AppColor / AppUIStyle
    │   ├── Managers/              # CoreData / Auth / Notification / IAP
    │   ├── Models/                # UserProfile / FastPlan / FoodModel / CoreData xcdatamodeld
    │   └── Services/              # FastTimer / UserProfile / AIFastPlan / HealthKit / FoodDatabase
    ├── Modules/
    │   ├── Timer/                 # TimerViewController / RingProgressView / StatsViewController
    │   ├── FastPlan/              # FastPlanSelectionViewController
    │   ├── Food/                  # RecordViewController / FoodSearchViewController / FoodCameraViewController
    │   ├── AI/                    # AIAssistantViewController
    │   ├── Settings/              # SettingsViewController
    │   └── Onboarding/            # OnboardingViewController / ProfileSetupViewController
    ├── Resources/
    │   ├── foods_database.json    # 14,999 条食物数据（5.7 MB）
    │   ├── Assets.xcassets/
    │   └── Localizable/           # en / de / fr
    ├── Widget/                    # FastingWidget (WidgetKit)
    └── Tests/                     # EmptyRhythmTests (10 个用例)
```

## 构建运行

```bash
# 生成 Xcode 项目
xcodegen generate

# 编译
xcodebuild -project EmptyRhythm.xcodeproj \
  -scheme EmptyRhythm \
  -destination 'platform=iOS Simulator,id=F2DB62DD-24B0-4AD5-9BF9-19FA4D7C783B' \
  build

# 运行测试
xcodebuild test \
  -project EmptyRhythm.xcodeproj \
  -scheme EmptyRhythmTests \
  -destination 'platform=iOS Simulator,id=F2DB62DD-24B0-4AD5-9BF9-19FA4D7C783B'
```

## 开发状态

- [x] 项目脚手架 + 设计系统
- [x] CoreData 8张表 + iCloud 同步
- [x] Apple 登录（Sign in with Apple）
- [x] 断食计时器核心
- [x] 断食方案库（6预设 + AI推荐）
- [x] 食物库 14,999 条
- [x] 饮食记录模块
- [x] 拍照识餐（Vision）
- [x] 体重追踪 + 周期预测
- [x] AI 助手页面
- [x] HealthKit 运动数据
- [x] WidgetKit 小组件
- [x] Settings 完整实现
- [x] Profile Setup 5步向导
- [x] 三语本地化（en/de/fr）
- [x] StoreKit2 IAP 买断 $3.99
- [ ] App Store 截图
- [ ] ASC 提审

## Bundle ID

`com.emptythythm.app`  
IAP: `com.emptythythm.app.pro`

---

*由 AI 辅助开发 · 空律工作室*
