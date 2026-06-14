import UIKit

// MARK: - 主 TabBar 控制器
class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let timerVC = makeNav(
            root: TimerViewController(),
            title: L("tab.timer"),
            image: "timer",
            selectedImage: "timer.fill"
        )

        let statsVC = makeNav(
            root: StatsViewController(),
            title: L("tab.stats"),
            image: "chart.bar",
            selectedImage: "chart.bar.fill"
        )

        let recordVC = makeNav(
            root: RecordViewController(),
            title: L("tab.record"),
            image: "fork.knife",
            selectedImage: "fork.knife"
        )

        let aiVC = makeNav(
            root: AIAssistantViewController(),
            title: L("tab.ai"),
            image: "sparkles",
            selectedImage: "sparkles"
        )

        let settingsVC = makeNav(
            root: SettingsViewController(),
            title: L("tab.settings"),
            image: "gearshape",
            selectedImage: "gearshape.fill"
        )

        viewControllers = [timerVC, statsVC, recordVC, aiVC, settingsVC]
    }

    private func makeNav(root: UIViewController, title: String, image: String, selectedImage: String) -> UINavigationController {
        root.title = title
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func setupAppearance() {
        tabBar.backgroundColor = AppColor.bgCard
        tabBar.tintColor = AppColor.mainTint
        tabBar.unselectedItemTintColor = AppColor.disabledGray

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.bgCard
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - 本地化快捷函数
func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}
