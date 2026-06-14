import UIKit
import CoreData

// MARK: - 饮食记录主页（Tab: Record）
class RecordViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let summaryCard = UIView()
    private let totalCalLabel = UILabel()
    private let remainCalLabel = UILabel()
    private let macroBar = MacroProgressBar()
    private let addButton = UIButton(type: .system)
    private let cameraButton = UIButton(type: .system)
    private let datePicker = UISegmentedControl(items: [L("record.today"), L("record.yesterday")])

    // MARK: - Data
    private var records: [DailyFoodRecord] = []
    private var groupedRecords: [(MealType, [DailyFoodRecord])] = []
    private var selectedDate = Calendar.current.startOfDay(for: Date())
    private var userProfile: UserProfileModel? { UserProfileService.shared.currentProfile }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setPageBackground()
        title = L("tab.record")
        setupNavBar()
        setupSummaryCard()
        setupTableView()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecords()
    }

    // MARK: - Setup
    private func setupNavBar() {
        let cameraItem = UIBarButtonItem(
            image: UIImage(systemName: "camera"),
            style: .plain, target: self, action: #selector(openCamera)
        )
        cameraItem.tintColor = AppColor.aiBlue
        let addItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addFood)
        )
        navigationItem.rightBarButtonItems = [addItem, cameraItem]

        datePicker.selectedSegmentIndex = 0
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        navigationItem.titleView = datePicker
    }

    private func setupSummaryCard() {
        summaryCard.setCardStyle()
        summaryCard.translatesAutoresizingMaskIntoConstraints = false

        totalCalLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        totalCalLabel.textColor = AppColor.mainTint
        totalCalLabel.textAlignment = .center
        totalCalLabel.translatesAutoresizingMaskIntoConstraints = false

        remainCalLabel.setCaptionStyle()
        remainCalLabel.textAlignment = .center
        remainCalLabel.translatesAutoresizingMaskIntoConstraints = false

        macroBar.translatesAutoresizingMaskIntoConstraints = false

        summaryCard.addSubview(totalCalLabel)
        summaryCard.addSubview(remainCalLabel)
        summaryCard.addSubview(macroBar)
        view.addSubview(summaryCard)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FoodRecordCell.self, forCellReuseIdentifier: FoodRecordCell.reuseID)
        tableView.backgroundColor = AppColor.bgPage
        tableView.rowHeight = 64
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppUIStyle.paddingM),
            summaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppUIStyle.paddingM),
            summaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppUIStyle.paddingM),

            totalCalLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: AppUIStyle.paddingM),
            totalCalLabel.centerXAnchor.constraint(equalTo: summaryCard.centerXAnchor),

            remainCalLabel.topAnchor.constraint(equalTo: totalCalLabel.bottomAnchor, constant: 4),
            remainCalLabel.centerXAnchor.constraint(equalTo: summaryCard.centerXAnchor),

            macroBar.topAnchor.constraint(equalTo: remainCalLabel.bottomAnchor, constant: AppUIStyle.paddingM),
            macroBar.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: AppUIStyle.paddingM),
            macroBar.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -AppUIStyle.paddingM),
            macroBar.heightAnchor.constraint(equalToConstant: 8),
            macroBar.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -AppUIStyle.paddingM),

            tableView.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: AppUIStyle.paddingS),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Data
    private func loadRecords() {
        let ctx = CoreDataManager.shared.context
        let req: NSFetchRequest<DailyFoodRecord> = DailyFoodRecord.fetchRequest()
        req.predicate = NSPredicate(format: "recordDate == %@", selectedDate as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: true)]
        records = (try? ctx.fetch(req)) ?? []

        // Group by meal type
        var groups: [Int16: [DailyFoodRecord]] = [:]
        for record in records {
            groups[record.mealType, default: []].append(record)
        }
        groupedRecords = MealType.allCases.compactMap { meal in
            guard let items = groups[meal.rawValue], !items.isEmpty else { return nil }
            return (meal, items)
        }

        updateSummary()
        tableView.reloadData()
    }

    private func updateSummary() {
        let totalCal = records.reduce(0) { $0 + $1.calorie * $1.foodWeight / 100 }
        let targetCal = userProfile?.dailyTargetCalorie ?? 2000
        let remaining = targetCal - totalCal

        totalCalLabel.text = "\(Int(totalCal)) kcal"
        if remaining >= 0 {
            remainCalLabel.text = String(format: L("record.remaining_cal"), Int(remaining))
            remainCalLabel.textColor = AppColor.textSub
        } else {
            remainCalLabel.text = String(format: L("record.over_cal"), Int(-remaining))
            remainCalLabel.textColor = AppColor.danger
        }

        let totalCarb = records.reduce(0) { $0 + $1.carb * $1.foodWeight / 100 }
        let totalProtein = records.reduce(0) { $0 + $1.protein * $1.foodWeight / 100 }
        let totalFat = records.reduce(0) { $0 + $1.fat * $1.foodWeight / 100 }
        macroBar.update(carb: totalCarb, protein: totalProtein, fat: totalFat)
    }

    // MARK: - Actions
    @objc private func addFood() {
        let vc = FoodSearchViewController()
        vc.onFoodSelected = { [weak self] food, weight, mealType in
            self?.saveRecord(food: food, weight: weight, mealType: mealType)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    @objc private func openCamera() {
        let vc = FoodCameraViewController()
        vc.onFoodSelected = { [weak self] food, weight, mealType in
            self?.saveRecord(food: food, weight: weight, mealType: mealType)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    @objc private func dateChanged() {
        if datePicker.selectedSegmentIndex == 0 {
            selectedDate = Calendar.current.startOfDay(for: Date())
        } else {
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
        }
        loadRecords()
    }

    private func saveRecord(food: FoodItem, weight: Double, mealType: MealType) {
        let ctx = CoreDataManager.shared.context
        let record = DailyFoodRecord(context: ctx)
        record.recordID = UUID().uuidString
        record.recordDate = selectedDate
        record.mealType = mealType.rawValue
        record.foodName = food.localizedName
        record.foodWeight = weight
        record.calorie = food.caloriesPer100g
        record.carb = food.carb
        record.protein = food.protein
        record.fat = food.fat
        record.createTime = Date()
        CoreDataManager.shared.save()
        loadRecords()
    }
}

// MARK: - TableView
extension RecordViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { groupedRecords.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupedRecords[section].1.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groupedRecords[section].0.displayName
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodRecordCell.reuseID, for: indexPath) as! FoodRecordCell
        cell.configure(with: groupedRecords[indexPath.section].1[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let record = groupedRecords[indexPath.section].1[indexPath.row]
        CoreDataManager.shared.context.delete(record)
        CoreDataManager.shared.save()
        loadRecords()
    }
}

// MARK: - MealType
enum MealType: Int16, CaseIterable {
    case breakfast = 0
    case lunch = 1
    case dinner = 2
    case snack = 3
    case drink = 4
    case lateNight = 5

    var displayName: String {
        switch self {
        case .breakfast:  return L("meal.breakfast")
        case .lunch:      return L("meal.lunch")
        case .dinner:     return L("meal.dinner")
        case .snack:      return L("meal.snack")
        case .drink:      return L("meal.drink")
        case .lateNight:  return L("meal.late_night")
        }
    }
}

// MARK: - FoodRecordCell
class FoodRecordCell: UITableViewCell {
    static let reuseID = "FoodRecordCell"

    private let nameLabel = UILabel()
    private let weightLabel = UILabel()
    private let calLabel = UILabel()
    private let macroLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppColor.bgCard

        nameLabel.setBodyStyle()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        weightLabel.setCaptionStyle()
        weightLabel.translatesAutoresizingMaskIntoConstraints = false

        calLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        calLabel.textColor = AppColor.mainTint
        calLabel.textAlignment = .right
        calLabel.translatesAutoresizingMaskIntoConstraints = false

        macroLabel.setCaptionStyle()
        macroLabel.textAlignment = .right
        macroLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(weightLabel)
        contentView.addSubview(calLabel)
        contentView.addSubview(macroLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: calLabel.leadingAnchor, constant: -8),

            weightLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            weightLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            weightLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            calLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            calLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            calLabel.widthAnchor.constraint(equalToConstant: 80),

            macroLabel.topAnchor.constraint(equalTo: calLabel.bottomAnchor, constant: 2),
            macroLabel.trailingAnchor.constraint(equalTo: calLabel.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with record: DailyFoodRecord) {
        nameLabel.text = record.foodName
        let weight = record.foodWeight
        weightLabel.text = "\(Int(weight))g"
        let cal = record.calorie * weight / 100
        calLabel.text = "\(Int(cal)) kcal"
        let p = record.protein * weight / 100
        let c = record.carb * weight / 100
        let f = record.fat * weight / 100
        macroLabel.text = "P\(Int(p)) C\(Int(c)) F\(Int(f))"
    }
}

// MARK: - MacroProgressBar
class MacroProgressBar: UIView {
    private let carbLayer = CALayer()
    private let proteinLayer = CALayer()
    private let fatLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        layer.masksToBounds = true
        backgroundColor = AppColor.lineSeparator
        [carbLayer, proteinLayer, fatLayer].forEach { layer.addSublayer($0) }
    }
    required init?(coder: NSCoder) { fatalError() }

    func update(carb: Double, protein: Double, fat: Double) {
        let total = carb * 4 + protein * 4 + fat * 9
        guard total > 0 else { return }
        let carbPct = (carb * 4) / total
        let proteinPct = (protein * 4) / total
        let fatPct = (fat * 9) / total
        let w = bounds.width
        carbLayer.frame = CGRect(x: 0, y: 0, width: w * carbPct, height: bounds.height)
        carbLayer.backgroundColor = UIColor.systemBlue.cgColor
        proteinLayer.frame = CGRect(x: w * carbPct, y: 0, width: w * proteinPct, height: bounds.height)
        proteinLayer.backgroundColor = AppColor.mainTint.cgColor
        fatLayer.frame = CGRect(x: w * (carbPct + proteinPct), y: 0, width: w * fatPct, height: bounds.height)
        fatLayer.backgroundColor = AppColor.warningOrange.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
