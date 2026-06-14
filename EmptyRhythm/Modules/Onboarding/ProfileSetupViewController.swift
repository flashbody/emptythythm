import UIKit

// MARK: - 用户体质档案录入（Onboarding + Settings 共用）
class ProfileSetupViewController: UIViewController {

    var onComplete: (() -> Void)?
    var isEditMode = false

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let stepLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let cardView = UIView()
    private let nextButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)

    // MARK: - Steps
    private enum Step: Int, CaseIterable {
        case gender = 0, age, body, goal, lifestyle
        var title: String {
            switch self {
            case .gender:    return L("profile.step.gender.title")
            case .age:       return L("profile.step.age.title")
            case .body:      return L("profile.step.body.title")
            case .goal:      return L("profile.step.goal.title")
            case .lifestyle: return L("profile.step.lifestyle.title")
            }
        }
        var subtitle: String {
            switch self {
            case .gender:    return L("profile.step.gender.subtitle")
            case .age:       return L("profile.step.age.subtitle")
            case .body:      return L("profile.step.body.subtitle")
            case .goal:      return L("profile.step.goal.subtitle")
            case .lifestyle: return L("profile.step.lifestyle.subtitle")
            }
        }
    }

    private var currentStep: Step = .gender
    private var stepViews: [UIView] = []

    // MARK: - Draft values
    private var gender: Gender = .female
    private var age: Int = 25
    private var height: Double = 165
    private var currentWeight: Double = 60
    private var targetWeight: Double = 55
    private var sportLevel: SportLevel = .sedentary
    private var workRestType: WorkRestType = .regular
    private var isGastroSensitive = false
    private var isGirlPeriodSensitive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setPageBackground()
        title = isEditMode ? L("settings.edit_profile") : L("profile.setup.title")
        if isEditMode {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: L("common.cancel"), style: .plain,
                target: self, action: #selector(dismissVC))
            loadExistingProfile()
        }
        setupUI()
        buildStepViews()
        showStep(.gender, animated: false)
    }

    private func loadExistingProfile() {
        guard let p = UserProfileService.shared.currentProfile else { return }
        gender = p.gender; age = p.age; height = p.height
        currentWeight = p.currentWeight; targetWeight = p.targetWeight
        sportLevel = p.sportLevel; workRestType = p.workRestType
        isGastroSensitive = p.isGastroSensitive
        isGirlPeriodSensitive = p.isGirlPeriodSensitive
    }

    // MARK: - UI Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        progressBar.progressTintColor = AppColor.mainTint
        progressBar.trackTintColor = AppColor.lineSeparator
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)

        stepLabel.setCaptionStyle()
        stepLabel.textAlignment = .right
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepLabel)

        titleLabel.setLargeTitleStyle()
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        subtitleLabel.setBodyStyle()
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        cardView.setCardStyle()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        nextButton.setTitle(L("common.next"), for: .normal)
        nextButton.setMainStyle()
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        contentView.addSubview(nextButton)

        backButton.setTitle(L("common.back"), for: .normal)
        backButton.setTextStyle()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.isHidden = true
        contentView.addSubview(backButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: stepLabel.leadingAnchor, constant: -8),
            progressBar.centerYAnchor.constraint(equalTo: stepLabel.centerYAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),

            stepLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            stepLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stepLabel.widthAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            nextButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 32),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 54),

            backButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 12),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    // MARK: - Step Views
    private func buildStepViews() {
        stepViews = Step.allCases.map { buildView(for: $0) }
    }

    private func buildView(for step: Step) -> UIView {
        switch step {
        case .gender:    return buildGenderView()
        case .age:       return buildAgeView()
        case .body:      return buildBodyView()
        case .goal:      return buildGoalView()
        case .lifestyle: return buildLifestyleView()
        }
    }

    // ── Step 1: Gender ───────────────────────────────────────────────────────
    private func buildGenderView() -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        for g in Gender.allCases {
            let btn = UIButton(type: .system)
            let icon = g == .female ? "♀" : "♂"
            btn.setTitle("\(icon)\n\(g.displayName)", for: .normal)
            btn.titleLabel?.numberOfLines = 2
            btn.titleLabel?.textAlignment = .center
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            btn.layer.cornerRadius = AppUIStyle.radiusLarge
            btn.layer.borderWidth = 2
            btn.tag = Int(g.rawValue)
            btn.addTarget(self, action: #selector(genderTapped(_:)), for: .touchUpInside)
            refreshGenderBtn(btn, selected: g == gender)
            stack.addArrangedSubview(btn)
        }

        let container = UIView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            stack.heightAnchor.constraint(equalToConstant: 100),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
        ])
        return container
    }

    @objc private func genderTapped(_ sender: UIButton) {
        gender = Gender(rawValue: Int16(sender.tag)) ?? .female
        guard let stack = sender.superview?.subviews.first as? UIStackView else { return }
        stack.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { btn in
            refreshGenderBtn(btn, selected: Int16(btn.tag) == gender.rawValue)
        }
    }

    private func refreshGenderBtn(_ btn: UIButton, selected: Bool) {
        btn.backgroundColor = selected ? AppColor.mainTint.withAlphaComponent(0.12) : AppColor.bgSecondary
        btn.layer.borderColor = selected ? AppColor.mainTint.cgColor : AppColor.lineSeparator.cgColor
        btn.setTitleColor(selected ? AppColor.mainTint : AppColor.textMain, for: .normal)
    }

    // ── Step 2: Age ──────────────────────────────────────────────────────────
    private func buildAgeView() -> UIView {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = 100
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectRow(max(0, age - 15), inComponent: 0, animated: false)

        let container = UIView()
        container.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 160),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])
        return container
    }

    // ── Step 3: Body ─────────────────────────────────────────────────────────
    private func buildBodyView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(numericRow(label: L("profile.height"), unit: "cm",
                                            value: "\(Int(height))", tag: 200))
        stack.addArrangedSubview(numericRow(label: L("profile.weight"), unit: "kg",
                                            value: String(format: "%.1f", currentWeight), tag: 201))

        let bmiLabel = UILabel()
        bmiLabel.setCaptionStyle()
        bmiLabel.textAlignment = .center
        bmiLabel.tag = 202
        refreshBMILabel(bmiLabel)
        stack.addArrangedSubview(bmiLabel)

        let container = UIView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
        ])
        return container
    }

    private func refreshBMILabel(_ label: UILabel) {
        guard height > 0 else { return }
        let bmi = currentWeight / ((height / 100) * (height / 100))
        let cat = BMICategory(bmi: bmi)
        label.text = "BMI \(String(format: "%.1f", bmi)) · \(cat.displayName)"
        label.textColor = cat.color
    }

    // ── Step 4: Goal ─────────────────────────────────────────────────────────
    private func buildGoalView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(numericRow(label: L("profile.target_weight"), unit: "kg",
                                            value: String(format: "%.1f", targetWeight), tag: 300))

        let predLabel = UILabel()
        predLabel.setCaptionStyle()
        predLabel.textAlignment = .center
        predLabel.numberOfLines = 0
        predLabel.tag = 301
        refreshPredLabel(predLabel)
        stack.addArrangedSubview(predLabel)

        let container = UIView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
        ])
        return container
    }

    private func refreshPredLabel(_ label: UILabel) {
        let diff = currentWeight - targetWeight
        if diff <= 0.5 {
            label.text = L("profile.goal.already_reached")
        } else {
            let weeks = Int(ceil((diff * 7700) / (500 * 7)))
            label.text = String(format: L("profile.goal.prediction"),
                                String(format: "%.1f", diff), weeks)
        }
    }

    // ── Step 5: Lifestyle ────────────────────────────────────────────────────
    private func buildLifestyleView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        let sportTitle = sectionLabel(L("profile.sport_level"))
        let sportSeg = UISegmentedControl(items: SportLevel.allCases.map { $0.displayName })
        sportSeg.selectedSegmentIndex = Int(sportLevel.rawValue)
        sportSeg.addTarget(self, action: #selector(sportChanged(_:)), for: .valueChanged)

        let workTitle = sectionLabel(L("profile.work_rest"))
        let workSeg = UISegmentedControl(items: WorkRestType.allCases.map { $0.displayName })
        workSeg.selectedSegmentIndex = Int(workRestType.rawValue)
        workSeg.addTarget(self, action: #selector(workRestChanged(_:)), for: .valueChanged)

        stack.addArrangedSubview(sportTitle)
        stack.addArrangedSubview(sportSeg)
        stack.addArrangedSubview(workTitle)
        stack.addArrangedSubview(workSeg)
        stack.addArrangedSubview(toggleRow(label: L("profile.gastro_sensitive"),
                                           isOn: isGastroSensitive, tag: 400))
        if gender == .female {
            stack.addArrangedSubview(toggleRow(label: L("profile.period_sensitive"),
                                               isOn: isGirlPeriodSensitive, tag: 401))
        }

        let container = UIView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
        ])
        return container
    }

    // MARK: - Reusable sub-views
    private func numericRow(label: String, unit: String, value: String, tag: Int) -> UIView {
        let row = UIView()
        let lbl = UILabel(); lbl.text = label; lbl.setBodyStyle()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(.required, for: .horizontal)

        let tf = UITextField()
        tf.text = value; tf.keyboardType = .decimalPad
        tf.textAlignment = .right; tf.font = AppUIStyle.fontSubTitle
        tf.textColor = AppColor.mainTint; tf.tag = tag
        tf.addTarget(self, action: #selector(numericFieldChanged(_:)), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false

        let unitLbl = UILabel(); unitLbl.text = unit; unitLbl.setCaptionStyle()
        unitLbl.translatesAutoresizingMaskIntoConstraints = false
        unitLbl.setContentHuggingPriority(.required, for: .horizontal)

        row.addSubview(lbl); row.addSubview(tf); row.addSubview(unitLbl)
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            unitLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            unitLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            tf.trailingAnchor.constraint(equalTo: unitLbl.leadingAnchor, constant: -4),
            tf.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            tf.widthAnchor.constraint(equalToConstant: 80),
            row.heightAnchor.constraint(equalToConstant: 44),
        ])
        return row
    }

    private func toggleRow(label: String, isOn: Bool, tag: Int) -> UIView {
        let row = UIView()
        let lbl = UILabel(); lbl.text = label; lbl.setBodyStyle()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        let sw = UISwitch(); sw.isOn = isOn; sw.onTintColor = AppColor.mainTint
        sw.tag = tag; sw.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        sw.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(lbl); row.addSubview(sw)
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            sw.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            sw.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 44),
        ])
        return row
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let l = UILabel(); l.text = text; l.setSubTitleStyle(); return l
    }

    // MARK: - Field Callbacks
    @objc private func numericFieldChanged(_ tf: UITextField) {
        let v = Double(tf.text ?? "") ?? 0
        switch tf.tag {
        case 200: height = v
        case 201: currentWeight = v
        case 300: targetWeight = v
        default: break
        }
        // Refresh BMI
        if tf.tag == 200 || tf.tag == 201,
           let card = stepViews[safe: Step.body.rawValue],
           let bmiLbl = card.viewWithTag(202) as? UILabel {
            refreshBMILabel(bmiLbl)
        }
        // Refresh prediction
        if tf.tag == 300,
           let card = stepViews[safe: Step.goal.rawValue],
           let predLbl = card.viewWithTag(301) as? UILabel {
            refreshPredLabel(predLbl)
        }
    }

    @objc private func sportChanged(_ seg: UISegmentedControl) {
        sportLevel = SportLevel(rawValue: Int16(seg.selectedSegmentIndex)) ?? .sedentary
    }
    @objc private func workRestChanged(_ seg: UISegmentedControl) {
        workRestType = WorkRestType(rawValue: Int16(seg.selectedSegmentIndex)) ?? .regular
    }
    @objc private func toggleChanged(_ sw: UISwitch) {
        if sw.tag == 400 { isGastroSensitive = sw.isOn }
        if sw.tag == 401 { isGirlPeriodSensitive = sw.isOn }
    }

    // MARK: - Navigation
    private func showStep(_ step: Step, animated: Bool) {
        currentStep = step
        let total = Step.allCases.count
        let idx = step.rawValue

        progressBar.setProgress(Float(idx + 1) / Float(total), animated: animated)
        stepLabel.text = "\(idx + 1)/\(total)"
        titleLabel.text = step.title
        subtitleLabel.text = step.subtitle
        nextButton.setTitle(idx == total - 1 ? L("common.done") : L("common.next"), for: .normal)
        backButton.isHidden = (idx == 0)

        cardView.subviews.forEach { $0.removeFromSuperview() }
        let sv = stepViews[idx]
        sv.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(sv)
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: cardView.topAnchor),
            sv.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            sv.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            sv.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
        ])
        if animated { UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() } }
        scrollView.setContentOffset(.zero, animated: animated)
    }

    @objc private func nextTapped() {
        view.endEditing(true)
        let idx = currentStep.rawValue
        if idx < Step.allCases.count - 1 {
            showStep(Step(rawValue: idx + 1)!, animated: true)
        } else {
            saveProfile()
        }
    }

    @objc private func backTapped() {
        let idx = currentStep.rawValue
        if idx > 0 { showStep(Step(rawValue: idx - 1)!, animated: true) }
    }

    @objc private func dismissVC() { dismiss(animated: true) }

    // MARK: - Save
    private func saveProfile() {
        let profile = UserProfileModel(
            userID: AuthManager.shared.currentUserID ?? UUID().uuidString,
            gender: gender, age: age,
            height: height, currentWeight: currentWeight, targetWeight: targetWeight,
            sportLevel: sportLevel, workRestType: workRestType,
            isGastroSensitive: isGastroSensitive,
            isGirlPeriodSensitive: isGirlPeriodSensitive
        )
        UserProfileService.shared.save(profile: profile)

        if isEditMode {
            navigationController?.popViewController(animated: true)
        } else {
            onComplete?()
            guard let window = view.window else { return }
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
                window.rootViewController = MainTabBarController()
            }
        }
    }
}

// MARK: - UIPickerViewDelegate / DataSource
extension ProfileSetupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 80 }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(row + 15) \(L("profile.years_old"))"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        age = row + 15
    }
}

// MARK: - Array safe subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
