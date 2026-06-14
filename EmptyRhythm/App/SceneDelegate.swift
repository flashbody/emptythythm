import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let authManager = AuthManager.shared
        if authManager.isLoggedIn {
            window.rootViewController = MainTabBarController()
        } else {
            window.rootViewController = UINavigationController(rootViewController: OnboardingViewController())
        }
        window.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 校正计时器
        FastTimerManager.shared.syncWithSystemTime()
    }
}
