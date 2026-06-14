import UIKit

// MARK: - 引导页（Sign in with Apple 强制登录）
class OnboardingViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let featureStack = UIStackView()
    private let signInButton = UIButton(type: .system)
    private let disclaimerLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.setPageBackground()
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Logo
        logoImageView.image = UIImage(systemName: "circle.dotted.circle")
        logoImageView.tintColor = AppColor.mainTint
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        // 标题
        titleLabel.text = L("onboarding.title")
        titleLabel.setLargeTitleStyle()
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppColor.mainTint
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 副标题
        subtitleLabel.text = L("onboarding.subtitle")
        subtitleLabel.setBodyStyle()
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // 功能列表
        featureStack.axis = .vertical
        featureStack.spacing = 16
        featureStack.translatesAutoresizingMaskIntoConstraints = false
        [
            ("timer", "onboarding.feature.timer"),
            ("fork.knife", "onboarding.feature.food"),
            ("chart.line.uptrend.xyaxis", "onboarding.feature.weight"),
            ("sparkles", "onboarding.feature.ai"),
            ("heart", "onboarding.feature.health")
        ].forEach { icon, key in
            featureStack.addArrangedSubview(makeFeatureRow(icon: icon, text: L(key)))
        }
        view.addSubview(featureStack)

        // Sign in with Apple 按钮
        signInButton.setTitle(L("onboarding.signin"), for: .normal)
        signInButton.setMainStyle()
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        view.addSubview(signInButton)

        // 免责声明
        disclaimerLabel.text = L("onboarding.disclaimer")
        disclaimerLabel.setCaptionStyle()
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(disclaimerLabel)

        // 加载指示器
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

    private func makeFeatureRow(icon: String, text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = AppColor.mainTint
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.setBodyStyle()
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 32)
        ])
        return container
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            featureStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            featureStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            featureStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),

            signInButton.bottomAnchor.constraint(equalTo: disclaimerLabel.topAnchor, constant: -16),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppUIStyle.paddingL),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppUIStyle.paddingL),
            signInButton.heightAnchor.constraint(equalToConstant: 54),

            disclaimerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            disclaimerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            disclaimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func signInTapped() {
        signInButton.isEnabled = false
        activityIndicator.startAnimating()

        AuthManager.shared.signIn(presentingVC: self) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.signInButton.isEnabled = true

                switch result {
                case .success:
                    self?.proceedToMain()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }

    private func proceedToMain() {
        let mainVC = MainTabBarController()
        guard let window = view.window else { return }
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
            window.rootViewController = mainVC
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: L("common.error"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L("common.ok"), style: .default))
        present(alert, animated: true)
    }
}
