import UIKit

// MARK: - 食物搜索页面
class FoodSearchViewController: UIViewController {

    var onFoodSelected: ((FoodItem, Double, MealType) -> Void)?

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private var allFoods: [FoodItem] = []
    private var filteredFoods: [FoodItem] = []
    private var selectedCategory: FoodCategory?
    private var selectedMealType: MealType = .lunch

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("food.search.title")
        view.setPageBackground()
        addDismissKeyboardGesture()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L("common.cancel"), style: .plain, target: self, action: #selector(dismiss_)
        )
        setupMealTypePicker()
        setupSearchController()
        setupCategoryBar()
        setupTableView()
        loadInitialFoods()
    }

    private func setupMealTypePicker() {
        let items = MealType.allCases.map { $0.displayName }
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = 1
        seg.addTarget(self, action: #selector(mealTypeChanged(_:)), for: .valueChanged)
        navigationItem.titleView = seg
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L("food.search.placeholder")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupCategoryBar() {
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        categoryCollectionView.backgroundColor = AppColor.bgPage
        categoryCollectionView.showsHorizontalScrollIndicator = false
        view.addSubview(categoryCollectionView)

        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FoodSearchCell.self, forCellReuseIdentifier: FoodSearchCell.reuseID)
        tableView.backgroundColor = AppColor.bgPage
        tableView.rowHeight = 72
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadInitialFoods() {
        DispatchQueue.global(qos: .userInitiated).async {
            let foods = FoodDatabaseService.shared.allFoods
            DispatchQueue.main.async {
                self.allFoods = foods
                self.filteredFoods = Array(foods.prefix(50))
                self.tableView.reloadData()
            }
        }
    }

    @objc private func mealTypeChanged(_ seg: UISegmentedControl) {
        selectedMealType = MealType.allCases[seg.selectedSegmentIndex]
    }

    @objc private func dismiss_() { dismiss(animated: true) }
}

extension FoodSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        DispatchQueue.global(qos: .userInitiated).async {
            let results: [FoodItem]
            if query.isEmpty {
                if let cat = self.selectedCategory {
                    results = Array(FoodDatabaseService.shared.foods(in: cat).prefix(50))
                } else {
                    results = Array(self.allFoods.prefix(50))
                }
            } else {
                results = FoodDatabaseService.shared.search(query: query)
            }
            DispatchQueue.main.async {
                self.filteredFoods = results
                self.tableView.reloadData()
            }
        }
    }
}

extension FoodSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { filteredFoods.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodSearchCell.reuseID, for: indexPath) as! FoodSearchCell
        cell.configure(with: filteredFoods[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let food = filteredFoods[indexPath.row]
        showWeightPicker(for: food)
    }

    private func showWeightPicker(for food: FoodItem) {
        let alert = UIAlertController(
            title: food.localizedName,
            message: L("food.enter_weight"),
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "100"
            tf.keyboardType = .numberPad
            tf.text = "100"
        }
        alert.addAction(UIAlertAction(title: L("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("common.add"), style: .default) { [weak self] _ in
            guard let self = self else { return }
            let weight = Double(alert.textFields?.first?.text ?? "100") ?? 100
            self.onFoodSelected?(food, weight, self.selectedMealType)
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

extension FoodSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        FoodCategory.allCases.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        if indexPath.item == 0 {
            cell.configure(title: L("food.all"), isSelected: selectedCategory == nil)
        } else {
            let cat = FoodCategory.allCases[indexPath.item - 1]
            cell.configure(title: "\(cat.icon) \(cat.displayName)", isSelected: selectedCategory == cat)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            selectedCategory = nil
            filteredFoods = Array(allFoods.prefix(50))
        } else {
            let cat = FoodCategory.allCases[indexPath.item - 1]
            selectedCategory = cat
            filteredFoods = Array(FoodDatabaseService.shared.foods(in: cat).prefix(50))
        }
        collectionView.reloadData()
        tableView.reloadData()
    }
}

// MARK: - FoodSearchCell
class FoodSearchCell: UITableViewCell {
    static let reuseID = "FoodSearchCell"
    private let nameLabel = UILabel()
    private let calLabel = UILabel()
    private let macroLabel = UILabel()
    private let scoreView = UIView()
    private let scoreLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppColor.bgCard
        accessoryType = .disclosureIndicator

        nameLabel.setBodyStyle()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        calLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        calLabel.textColor = AppColor.mainTint
        calLabel.translatesAutoresizingMaskIntoConstraints = false

        macroLabel.setCaptionStyle()
        macroLabel.translatesAutoresizingMaskIntoConstraints = false

        scoreView.layer.cornerRadius = 10
        scoreView.translatesAutoresizingMaskIntoConstraints = false

        scoreLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreView.addSubview(scoreLabel)

        contentView.addSubview(nameLabel)
        contentView.addSubview(calLabel)
        contentView.addSubview(macroLabel)
        contentView.addSubview(scoreView)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: scoreView.leadingAnchor, constant: -8),

            calLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            calLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            macroLabel.topAnchor.constraint(equalTo: calLabel.bottomAnchor, constant: 2),
            macroLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            macroLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            scoreView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            scoreView.widthAnchor.constraint(equalToConstant: 44),
            scoreView.heightAnchor.constraint(equalToConstant: 20),

            scoreLabel.centerXAnchor.constraint(equalTo: scoreView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreView.centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with food: FoodItem) {
        nameLabel.text = food.localizedName
        calLabel.text = "\(Int(food.caloriesPer100g)) kcal/100g"
        macroLabel.text = "P\(Int(food.protein))g C\(Int(food.carb))g F\(Int(food.fat))g"
        scoreLabel.text = "断食\(food.fastingScore)"
        let color: UIColor = food.fastingScore >= 8 ? AppColor.mainTint : food.fastingScore >= 5 ? AppColor.warningOrange : AppColor.danger
        scoreView.backgroundColor = color
    }
}

// MARK: - CategoryCell
class CategoryCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, isSelected: Bool) {
        label.text = title
        contentView.backgroundColor = isSelected ? AppColor.mainTint : AppColor.bgSecondary
        label.textColor = isSelected ? .white : AppColor.textMain
    }
}
