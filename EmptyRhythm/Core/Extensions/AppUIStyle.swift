import UIKit

// MARK: - 全局 UI 样式系统
struct AppUIStyle {

    // MARK: 圆角
    static let radiusSmall: CGFloat = 6
    static let radiusNormal: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXL: CGFloat = 24

    // MARK: 阴影
    static let shadowOpacity: Float = 0.08
    static let shadowRadius: CGFloat = 6
    static let shadowOffset = CGSize(width: 0, height: 2)

    // MARK: 字体
    static let fontLargeTitle = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let fontTitle = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let fontSubTitle = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let fontBody = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let fontCaption = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let fontMono = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .thin)
    static let fontMonoSmall = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .light)

    // MARK: 间距
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let paddingXL: CGFloat = 32
}

// MARK: - UIButton 全局样式扩展
extension UIButton {

    func setMainStyle() {
        backgroundColor = AppColor.mainTint
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppUIStyle.fontSubTitle
        layer.cornerRadius = AppUIStyle.radiusNormal
        layer.masksToBounds = false
        applyShadow(color: AppColor.mainTint)
    }

    func setAuxStyle() {
        backgroundColor = AppColor.bgCard
        setTitleColor(AppColor.textMain, for: .normal)
        titleLabel?.font = AppUIStyle.fontSubTitle
        layer.cornerRadius = AppUIStyle.radiusNormal
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = AppColor.lineSeparator.cgColor
    }

    func setTextStyle() {
        backgroundColor = .clear
        setTitleColor(AppColor.mainTint, for: .normal)
        titleLabel?.font = AppUIStyle.fontBody
    }

    func setAIStyle() {
        backgroundColor = AppColor.aiBlue
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppUIStyle.fontSubTitle
        layer.cornerRadius = AppUIStyle.radiusNormal
        layer.masksToBounds = false
        applyShadow(color: AppColor.aiBlue)
    }

    func setWarningStyle() {
        backgroundColor = AppColor.warningOrange
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppUIStyle.fontSubTitle
        layer.cornerRadius = AppUIStyle.radiusNormal
        layer.masksToBounds = true
    }

    func setDestructiveStyle() {
        backgroundColor = AppColor.danger
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppUIStyle.fontSubTitle
        layer.cornerRadius = AppUIStyle.radiusNormal
        layer.masksToBounds = true
    }
}

// MARK: - UIView 全局样式扩展
extension UIView {

    func setCardStyle() {
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppUIStyle.radiusLarge
        layer.masksToBounds = false
        applyShadow(color: .black, opacity: 0.05)
    }

    func setPageBackground() {
        backgroundColor = AppColor.bgPage
    }

    func applyShadow(
        color: UIColor = .black,
        opacity: Float = AppUIStyle.shadowOpacity,
        radius: CGFloat = AppUIStyle.shadowRadius,
        offset: CGSize = AppUIStyle.shadowOffset
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }

    static func separator() -> UIView {
        let v = UIView()
        v.backgroundColor = AppColor.lineSeparator
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([v.heightAnchor.constraint(equalToConstant: 0.5)])
        return v
    }
}

// MARK: - UILabel 全局样式扩展
extension UILabel {

    func setLargeTitleStyle() {
        textColor = AppColor.textMain
        font = AppUIStyle.fontLargeTitle
        numberOfLines = 0
    }

    func setTitleStyle() {
        textColor = AppColor.textMain
        font = AppUIStyle.fontTitle
        numberOfLines = 0
    }

    func setSubTitleStyle() {
        textColor = AppColor.textMain
        font = AppUIStyle.fontSubTitle
        numberOfLines = 0
    }

    func setBodyStyle() {
        textColor = AppColor.textMain
        font = AppUIStyle.fontBody
        numberOfLines = 0
    }

    func setCaptionStyle() {
        textColor = AppColor.textSub
        font = AppUIStyle.fontCaption
        numberOfLines = 0
    }

    func setAIHighlightStyle() {
        textColor = AppColor.aiBlue
        font = AppUIStyle.fontSubTitle
    }

    func setWarningStyle() {
        textColor = AppColor.warningOrange
        font = AppUIStyle.fontBody
    }
}

// MARK: - AppearanceManager
struct AppearanceManager {
    static func configure() {
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = AppColor.mainTint
        tabBar.unselectedItemTintColor = AppColor.disabledGray

        let navBar = UINavigationBar.appearance()
        navBar.tintColor = AppColor.mainTint
        navBar.titleTextAttributes = [
            .foregroundColor: AppColor.textMain,
            .font: AppUIStyle.fontSubTitle
        ]
        navBar.largeTitleTextAttributes = [
            .foregroundColor: AppColor.textMain,
            .font: AppUIStyle.fontTitle
        ]
    }
}

// MARK: - UIViewController 通用扩展
extension UIViewController {

    /// 点击空白收起键盘（cancelsTouchesInView=false 不影响其他点击）
    func addDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardGlobal))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    /// 为 ScrollView / TableView / CollectionView 设置拖动收起键盘
    func addKeyboardDismissOnScroll(_ scrollViews: UIScrollView...) {
        scrollViews.forEach { $0.keyboardDismissMode = .onDrag }
    }

    @objc private func dismissKeyboardGlobal() {
        view.endEditing(true)
    }
}
