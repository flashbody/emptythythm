import UIKit
import StoreKit
import CoreData
import UserNotifications

// MARK: - 设置页面
class SettingsViewController: UIViewController {

    // MARK: - Section / Row 枚举
    private enum Section: Int, CaseIterable {
        case profile, notifications, ai, appearance, privacy, iap, about
        var title: String {
            switch self {
            case .profile:       return L("settings.section.profile")
            case .notifications: return L("settings.section.notifications")
            case .ai:            return L("settings.section.ai")
            case .appearance:    return L("settings.section.appearance")
            case .privacy:       return L("settings.section.privacy")
            case .iap:           return L("settings.section.iap")
            case .about:         return L("settings.section.about")
            }
        }
    }

    private enum Row {
        // Profile
        case editProfile
        // Notifications
        case notifyFastStart, notifyEatWindow, notifyEatClose, notifyDailyProgress
        // AI
        case aiEnabled, aiWeeklyReport, clearAIHistory
        // Appearance
        case appearanceMode
        // Privacy
        case clearLocalData, clearCloudData
        // IAP
        case upgradePro, restorePurchase
        // About
        case version, privacyPolicy, termsOfService, rateApp, contactUs
    }

    private let sections: [[Row]] = [
        [.editProfile],
        [.notifyFastStart, .notifyEatWindow, .notifyEatClose, .notifyDailyProgress],
        [.aiEnabled, .aiWeeklyReport, .clearAIHistory],
        [.appearanceMode],
        [.clearLocalData, .clearCloudData],
        [.upgradePro, .restorePurchase],
        [.version, .privacyPolicy, .termsOfService, .rateApp, .contactUs],
    ]

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - UserDefaults Keys
    private let kNotifyFastStart    = "er_notify_fast_start"
    private let kNotifyEatWindow    = "er_notify_eat_window"
    private let kNotifyEatClose     = "er_notify_eat_close"
    private let kNotifyDailyProgress = "er_notify_daily_progress"
    private let kAIEnabled          = "er_ai_enabled"
    private let kAIWeeklyReport     = "er_ai_weekly_report"
    private let kAppearanceMode     = "er_appearance_mode"  // 0=system,1=light,2=dark

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setPageBackground()
        title = L("tab.settings")
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseID)
        tableView.backgroundColor = AppColor.bgPage
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Cell builders
    private func cell(for row: Row, at indexPath: IndexPath) -> UITableViewCell {
        switch row {

        // ── Switches ──────────────────────────────────────────────────────────
        case .notifyFastStart:
            return switchCell(title: L("settings.notify.fast_start"),
                              key: kNotifyFastStart, defaultOn: true,
                              onChange: { [weak self] on in self?.toggleNotification(.fastStart, on: on) })
        case .notifyEatWindow:
            return switchCell(title: L("settings.notify.eat_window"),
                              key: kNotifyEatWindow, defaultOn: true,
                              onChange: { [weak self] on in self?.toggleNotification(.eatWindow, on: on) })
        case .notifyEatClose:
            return switchCell(title: L("settings.notify.eat_close"),
                              key: kNotifyEatClose, defaultOn: true,
                              onChange: nil)
        case .notifyDailyProgress:
            return switchCell(title: L("settings.notify.daily_progress"),
                              key: kNotifyDailyProgress, defaultOn: false,
                              onChange: { [weak self] on in
                                  if on { NotificationManager.shared.scheduleDailyProgressReminder() }
                              })
        case .aiEnabled:
            return switchCell(title: L("settings.ai.enabled"),
                              key: kAIEnabled, defaultOn: true, onChange: nil)
        case .aiWeeklyReport:
            return switchCell(title: L("settings.ai.weekly_report"),
                              key: kAIWeeklyReport, defaultOn: true, onChange: nil)

        // ── Disclosure / Action ───────────────────────────────────────────────
        case .editProfile:
            return disclosureCell(title: L("settings.edit_profile"),
                                  subtitle: profileSubtitle(), icon: "person.circle")
        case .clearAIHistory:
            return actionCell(title: L("settings.ai.clear_history"),
                              color: AppColor.warningOrange, icon: "trash")
        case .appearanceMode:
            let modes = [L("settings.appearance.system"),
                         L("settings.appearance.light"),
                         L("settings.appearance.dark")]
            let current = UserDefaults.standard.integer(forKey: kAppearanceMode)
            return disclosureCell(title: L("settings.appearance"),
                                  subtitle: modes[current], icon: "circle.lefthalf.filled")
        case .clearLocalData:
            return actionCell(title: L("settings.privacy.clear_local"),
                              color: AppColor.danger, icon: "trash.fill")
        case .clearCloudData:
            return actionCell(title: L("settings.privacy.clear_cloud"),
                              color: AppColor.danger, icon: "icloud.slash")
        case .upgradePro:
            if IAPManager.shared.isProUnlocked {
                return infoCell(title: L("settings.iap.pro_unlocked"), icon: "checkmark.seal.fill", color: AppColor.mainTint)
            }
            return actionCell(title: L("settings.iap.upgrade"), color: AppColor.mainTint, icon: "star.fill")
        case .restorePurchase:
            return disclosureCell(title: L("settings.iap.restore"), subtitle: nil, icon: "arrow.clockwise")
        case .version:
            let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            return infoCell(title: L("settings.about.version"), detail: "v\(v) (\(b))", icon: "info.circle")
        case .privacyPolicy:
            return disclosureCell(title: L("settings.about.privacy"), subtitle: nil, icon: "hand.raised")
        case .termsOfService:
            return disclosureCell(title: L("settings.about.terms"), subtitle: nil, icon: "doc.text")
        case .rateApp:
            return disclosureCell(title: L("settings.about.rate"), subtitle: nil, icon: "star")
        case .contactUs:
            return disclosureCell(title: L("settings.about.contact"), subtitle: nil, icon: "envelope")
        }
    }

    // MARK: - Cell Helpers
    private func switchCell(title: String, key: String, defaultOn: Bool,
                            onChange: ((Bool) -> Void)?) -> SwitchCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseID) as! SwitchCell
        let isOn = UserDefaults.standard.object(forKey: key) == nil
            ? defaultOn
            : UserDefaults.standard.bool(forKey: key)
        cell.configure(title: title, isOn: isOn) { [weak self] on in
            UserDefaults.standard.set(on, forKey: key)
            onChange?(on)
        }
        return cell
    }

    private func disclosureCell(title: String, subtitle: String?, icon: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.textLabel?.font = AppUIStyle.fontBody
        cell.textLabel?.textColor = AppColor.textMain
        cell.detailTextLabel?.text = subtitle
        cell.detailTextLabel?.textColor = AppColor.textSub
        cell.imageView?.image = UIImage(systemName: icon)
        cell.imageView?.tintColor = AppColor.mainTint
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = AppColor.bgCard
        return cell
    }

    private func actionCell(title: String, color: UIColor, icon: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.textLabel?.font = AppUIStyle.fontBody
        cell.textLabel?.textColor = color
        cell.imageView?.image = UIImage(systemName: icon)
        cell.imageView?.tintColor = color
        cell.backgroundColor = AppColor.bgCard
        return cell
    }

    private func infoCell(title: String, detail: String? = nil, icon: String, color: UIColor = AppColor.mainTint) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.textLabel?.font = AppUIStyle.fontBody
        cell.textLabel?.textColor = AppColor.textMain
        cell.detailTextLabel?.text = detail
        cell.detailTextLabel?.textColor = AppColor.textSub
        cell.imageView?.image = UIImage(systemName: icon)
        cell.imageView?.tintColor = color
        cell.backgroundColor = AppColor.bgCard
        cell.selectionStyle = .none
        return cell
    }

    private func profileSubtitle() -> String? {
        guard let p = UserProfileService.shared.currentProfile else { return L("settings.profile.not_set") }
        return "\(p.gender.displayName) · BMI \(String(format: "%.1f", p.bmi)) · \(p.bmiCategory.displayName)"
    }

    // MARK: - Notification helpers
    private enum NotifType { case fastStart, eatWindow }
    private func toggleNotification(_ type: NotifType, on: Bool) {
        guard on else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            return
        }
        NotificationManager.shared.checkAuthorizationStatus { status in
            if status == .notDetermined {
                NotificationManager.shared.requestAuthorization { _ in }
            }
        }
    }

    // MARK: - Actions
    private func handleRowTap(_ row: Row) {
        switch row {
        case .editProfile:
            let vc = ProfileSetupViewController()
            vc.isEditMode = true
            navigationController?.pushViewController(vc, animated: true)

        case .appearanceMode:
            showAppearancePicker()

        case .clearAIHistory:
            confirmAction(title: L("settings.ai.clear_history"),
                          message: L("settings.ai.clear_history.confirm")) {
                self.clearAIHistory()
            }

        case .clearLocalData:
            confirmAction(title: L("settings.privacy.clear_local"),
                          message: L("settings.privacy.clear_local.confirm"),
                          isDestructive: true) {
                self.clearAllLocalData()
            }

        case .clearCloudData:
            confirmAction(title: L("settings.privacy.clear_cloud"),
                          message: L("settings.privacy.clear_cloud.confirm"),
                          isDestructive: true) {
                self.clearCloudData()
            }

        case .upgradePro:
            guard !IAPManager.shared.isProUnlocked else { return }
            Task { @MainActor in
                do {
                    try await IAPManager.shared.purchase()
                    self.tableView.reloadData()
                    self.showAlert(title: L("settings.iap.success"), message: L("settings.iap.success.msg"))
                } catch {
                    if case IAPError.userCancelled = error { return }
                    self.showAlert(title: L("common.error"), message: error.localizedDescription)
                }
            }

        case .restorePurchase:
            Task { @MainActor in
                do {
                    try await IAPManager.shared.restore()
                    self.tableView.reloadData()
                    self.showAlert(title: L("settings.iap.restored"), message: L("settings.iap.restored.msg"))
                } catch {
                    self.showAlert(title: L("common.error"), message: error.localizedDescription)
                }
            }

        case .privacyPolicy:
            openURL("https://flashbody.github.io/emptythythm/privacy.html")

        case .termsOfService:
            openURL("https://flashbody.github.io/emptythythm/terms.html")

        case .rateApp:
            if let scene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }

        case .contactUs:
            openURL("mailto:support@emptythythm.app")

        default: break
        }
    }

    // MARK: - Appearance Picker
    private func showAppearancePicker() {
        let alert = UIAlertController(title: L("settings.appearance"), message: nil, preferredStyle: .actionSheet)
        let modes: [(String, UIUserInterfaceStyle, Int)] = [
            (L("settings.appearance.system"), .unspecified, 0),
            (L("settings.appearance.light"),  .light,       1),
            (L("settings.appearance.dark"),   .dark,        2),
        ]
        let current = UserDefaults.standard.integer(forKey: kAppearanceMode)
        for (title, style, idx) in modes {
            let action = UIAlertAction(title: idx == current ? "✓ \(title)" : title, style: .default) { [weak self] _ in
                UserDefaults.standard.set(idx, forKey: self?.kAppearanceMode ?? "")
                self?.applyAppearance(style)
                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: L("common.cancel"), style: .cancel))
        present(alert, animated: true)
    }

    private func applyAppearance(_ style: UIUserInterfaceStyle) {
        view.window?.overrideUserInterfaceStyle = style
    }

    // MARK: - Data Clearing
    private func clearAIHistory() {
        let ctx = CoreDataManager.shared.context
        let req: NSFetchRequest<NSFetchRequestResult> = AIChatRecord.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: req)
        try? ctx.execute(delete)
        CoreDataManager.shared.save()
        showAlert(title: L("common.done"), message: L("settings.ai.cleared"))
    }

    private func clearAllLocalData() {
        let ctx = CoreDataManager.shared.context
        for entity in ["DailyFoodRecord", "WeightRecord", "AIChatRecord", "AIWeeklyReport", "HealthRecord", "UserProfile"] {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let delete = NSBatchDeleteRequest(fetchRequest: req)
            try? ctx.execute(delete)
        }
        CoreDataManager.shared.save()
        UserDefaults.standard.removeObject(forKey: "er_fast_start_date")
        UserDefaults.standard.removeObject(forKey: "er_fast_plan_id")
        UserDefaults.standard.removeObject(forKey: "er_fast_state")
        showAlert(title: L("common.done"), message: L("settings.privacy.cleared"))
    }

    private func clearCloudData() {
        let ctx = CoreDataManager.shared.context
        for entity in ["FastPlan", "FastRecord"] {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let delete = NSBatchDeleteRequest(fetchRequest: req)
            try? ctx.execute(delete)
        }
        CoreDataManager.shared.save()
        showAlert(title: L("common.done"), message: L("settings.privacy.cloud_cleared"))
    }

    // MARK: - Helpers
    private func confirmAction(title: String, message: String,
                               isDestructive: Bool = false, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("common.confirm"), style: isDestructive ? .destructive : .default) { _ in action() })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("common.ok"), style: .default))
        present(alert, animated: true)
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - UITableViewDelegate / DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell(for: sections[indexPath.section][indexPath.row], at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleRowTap(sections[indexPath.section][indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50 }
}

// MARK: - SwitchCell
class SwitchCell: UITableViewCell {
    static let reuseID = "SwitchCell"
    private let toggle = UISwitch()
    private var onChange: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppColor.bgCard
        selectionStyle = .none
        toggle.onTintColor = AppColor.mainTint
        toggle.addTarget(self, action: #selector(toggled), for: .valueChanged)
        accessoryView = toggle
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) {
        textLabel?.text = title
        textLabel?.font = AppUIStyle.fontBody
        textLabel?.textColor = AppColor.textMain
        toggle.isOn = isOn
        self.onChange = onChange
    }

    @objc private func toggled() { onChange?(toggle.isOn) }
}
