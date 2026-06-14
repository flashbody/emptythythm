import UIKit

// MARK: - 断食方案选择页
class FastPlanSelectionViewController: UIViewController {

    var onPlanSelected: ((FastPlanModel) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var plans: [FastPlanModel] = []
    private var aiRecommendedPlan: FastPlanModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("plan.select.title")
        view.setPageBackground()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L("common.cancel"), style: .plain, target: self, action: #selector(dismiss_)
        )
        loadPlans()
        setupTableView()
    }

    private func loadPlans() {
        if let profile = UserProfileService.shared.currentProfile {
            plans = PresetFastPlan.availablePlans(for: profile)
            aiRecommendedPlan = AIFastPlanEngine.shared.recommendPlan(for: profile)
        } else {
            plans = PresetFastPlan.allCases.map { $0.model }
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FastPlanCell.self, forCellReuseIdentifier: FastPlanCell.reuseID)
        tableView.backgroundColor = AppColor.bgPage
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func dismiss_() { dismiss(animated: true) }
}

extension FastPlanSelectionViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return aiRecommendedPlan != nil ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if aiRecommendedPlan != nil && section == 0 { return 1 }
        return plans.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if aiRecommendedPlan != nil && section == 0 { return L("plan.ai_recommend") }
        return L("plan.preset_plans")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FastPlanCell.reuseID, for: indexPath) as! FastPlanCell
        if aiRecommendedPlan != nil && indexPath.section == 0 {
            cell.configure(with: aiRecommendedPlan!, isRecommended: true)
        } else {
            cell.configure(with: plans[indexPath.row], isRecommended: false)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let plan: FastPlanModel
        if aiRecommendedPlan != nil && indexPath.section == 0 {
            plan = aiRecommendedPlan!
        } else {
            plan = plans[indexPath.row]
        }
        onPlanSelected?(plan)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}

// MARK: - 方案 Cell
class FastPlanCell: UITableViewCell {

    static let reuseID = "FastPlanCell"

    private let nameLabel = UILabel()
    private let descLabel = UILabel()
    private let durationLabel = UILabel()
    private let recommendBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = AppColor.bgCard
        accessoryType = .disclosureIndicator

        nameLabel.setSubTitleStyle()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        descLabel.setCaptionStyle()
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        durationLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        durationLabel.textColor = AppColor.mainTint
        durationLabel.adjustsFontSizeToFitWidth = true
        durationLabel.minimumScaleFactor = 0.7
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        recommendBadge.text = "AI"
        recommendBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        recommendBadge.textColor = .white
        recommendBadge.backgroundColor = AppColor.aiBlue
        recommendBadge.layer.cornerRadius = 8
        recommendBadge.clipsToBounds = true
        recommendBadge.textAlignment = .center
        recommendBadge.translatesAutoresizingMaskIntoConstraints = false
        recommendBadge.isHidden = true

        contentView.addSubview(nameLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(recommendBadge)

        NSLayoutConstraint.activate([
            durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            durationLabel.widthAnchor.constraint(equalToConstant: 88),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: recommendBadge.leadingAnchor, constant: -8),

            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            descLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),

            recommendBadge.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            recommendBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            recommendBadge.widthAnchor.constraint(equalToConstant: 28),
            recommendBadge.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    func configure(with plan: FastPlanModel, isRecommended: Bool) {
        nameLabel.text = plan.name
        descLabel.text = plan.planDesc
        durationLabel.text = plan.displayName
        recommendBadge.isHidden = !isRecommended
        if isRecommended {
            durationLabel.textColor = AppColor.aiBlue
        } else {
            durationLabel.textColor = AppColor.mainTint
        }
    }
}
