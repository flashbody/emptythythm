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

        // 先显示启动页
        let launchVC = LaunchViewController()
        window.rootViewController = launchVC
        window.makeKeyAndVisible()

        // 2.2秒后过渡到主界面
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            let mainVC: UIViewController

            #if targetEnvironment(simulator)
            // 模拟器不支持 Sign in with Apple，直接进主界面
            mainVC = MainTabBarController()
            #else
            if AuthManager.shared.isLoggedIn {
                mainVC = MainTabBarController()
            } else {
                mainVC = UINavigationController(rootViewController: OnboardingViewController())
            }
            #endif
            UIView.transition(with: window, duration: 0.5,
                              options: .transitionCrossDissolve) {
                window.rootViewController = mainVC
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 校正计时器
        FastTimerManager.shared.syncWithSystemTime()
    }
}
