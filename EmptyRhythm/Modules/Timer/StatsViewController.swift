import UIKit
import CoreData

// MARK: - 体重追踪 + 周期预测（Tab: Stats）
class StatsViewController: UIViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let weightCard = UIView()
    private let weightLabel = UILabel()
    private let weightChangeLabel = UILabel()
    private let addWeightButton = UIButton(type: .system)
    private let chartView = WeightChartView()
    private let predictionCard = UIView()
    private let predictionTitle = UILabel()
    private let predictionContent = UILabel()
    private let fastingStatsCard = UIView()
    private let weeklyReportCard = UIView()
    private let weeklyReportContent = UILabel()

    // MARK: - Data
    private var weightRecords: [WeightRecord] = []
    private var fastRecords: [FastRecord] = []
    private var userProfile: UserProfileModel? { UserProfileService.shared.currentProfile }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setPageBackground()
        addDismissKeyboardGesture()
        addKeyboardDismissOnScroll(scrollView)
        title = L("tab.stats")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle"),
            style: .plain, target: self, action: #selector(addWeight)
        )
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    // MARK: - Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Weight card
        weightCard.setCardStyle()
        weightCard.translatesAutoresizingMaskIntoConstraints = false

        weightLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        weightLabel.textColor = AppColor.mainTint
        weightLabel.textAlignment = .center
        weightLabel.translatesAutoresizingMaskIntoConstraints = false

        weightChangeLabel.setCaptionStyle()
        weightChangeLabel.textAlignment = .center
        weightChangeLabel.translatesAutoresizingMaskIntoConstraints = false

        addWeightButton.setTitle(L("stats.log_weight"), for: .normal)
        addWeightButton.setMainStyle()
        addWeightButton.translatesAutoresizingMaskIntoConstraints = false
        addWeightButton.addTarget(self, action: #selector(addWeight), for: .touchUpInside)

        weightCard.addSubview(weightLabel)
        weightCard.addSubview(weightChangeLabel)
        weightCard.addSubview(addWeightButton)
        contentView.addSubview(weightCard)

        // Chart
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.setCardStyle()
        contentView.addSubview(chartView)

        // Prediction card
        predictionCard.setCardStyle()
        predictionCard.translatesAutoresizingMaskIntoConstraints = false

        predictionTitle.setSubTitleStyle()
        predictionTitle.text = L("stats.prediction_title")
        predictionTitle.translatesAutoresizingMaskIntoConstraints = false

        predictionContent.setBodyStyle()
        predictionContent.numberOfLines = 0
        predictionContent.translatesAutoresizingMaskIntoConstraints = false

        predictionCard.addSubview(predictionTitle)
        predictionCard.addSubview(predictionContent)
        contentView.addSubview(predictionCard)

        // Fasting stats card
        fastingStatsCard.setCardStyle()
        fastingStatsCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fastingStatsCard)
        setupFastingStats()

        // Weekly AI report
        weeklyReportCard.setCardStyle()
        weeklyReportCard.translatesAutoresizingMaskIntoConstraints = false

        let reportTitle = UILabel()
        reportTitle.setSubTitleStyle()
        reportTitle.text = L("stats.weekly_report")
        reportTitle.translatesAutoresizingMaskIntoConstraints = false

        let aiIcon = UIImageView(image: UIImage(systemName: "sparkles"))
        aiIcon.tintColor = AppColor.aiBlue
        aiIcon.translatesAutoresizingMaskIntoConstraints = false

        weeklyReportContent.setBodyStyle()
        weeklyReportContent.numberOfLines = 0
        weeklyReportContent.translatesAutoresizingMaskIntoConstraints = false

        weeklyReportCard.addSubview(aiIcon)
        weeklyReportCard.addSubview(reportTitle)
        weeklyReportCard.addSubview(weeklyReportContent)
        contentView.addSubview(weeklyReportCard)

        NSLayoutConstraint.activate([
            aiIcon.topAnchor.constraint(equalTo: weeklyReportCard.topAnchor, constant: AppUIStyle.paddingM),
            aiIcon.leadingAnchor.constraint(equalTo: weeklyReportCard.leadingAnchor, constant: AppUIStyle.paddingM),
            aiIcon.widthAnchor.constraint(equalToConstant: 20),
            aiIcon.heightAnchor.constraint(equalToConstant: 20),
            reportTitle.centerYAnchor.constraint(equalTo: aiIcon.centerYAnchor),
            reportTitle.leadingAnchor.constraint(equalTo: aiIcon.trailingAnchor, constant: 8),
            weeklyReportContent.topAnchor.constraint(equalTo: reportTitle.bottomAnchor, constant: 8),
            weeklyReportContent.leadingAnchor.constraint(equalTo: weeklyReportCard.leadingAnchor, constant: AppUIStyle.paddingM),
            weeklyReportContent.trailingAnchor.constraint(equalTo: weeklyReportCard.trailingAnchor, constant: -AppUIStyle.paddingM),
            weeklyReportContent.bottomAnchor.constraint(equalTo: weeklyReportCard.bottomAnchor, constant: -AppUIStyle.paddingM),
        ])
    }

    private func setupFastingStats() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let streakItem = makeStatItem(value: "0", label: L("stats.streak"), color: AppColor.mainTint)
        let successItem = makeStatItem(value: "0", label: L("stats.success_rate"), color: AppColor.aiBlue)
        let avgItem = makeStatItem(value: "0h", label: L("stats.avg_fast"), color: AppColor.warningOrange)

        stackView.addArrangedSubview(streakItem)
        stackView.addArrangedSubview(successItem)
        stackView.addArrangedSubview(avgItem)
        fastingStatsCard.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: fastingStatsCard.topAnchor, constant: AppUIStyle.paddingM),
            stackView.leadingAnchor.constraint(equalTo: fastingStatsCard.leadingAnchor, constant: AppUIStyle.paddingS),
            stackView.trailingAnchor.constraint(equalTo: fastingStatsCard.trailingAnchor, constant: -AppUIStyle.paddingS),
            stackView.bottomAnchor.constraint(equalTo: fastingStatsCard.bottomAnchor, constant: -AppUIStyle.paddingM),
        ])
    }

    private func makeStatItem(value: String, label: String, color: UIColor) -> UIView {
        let v = UIView()
        let vl = UILabel()
        vl.text = value
        vl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        vl.textColor = color
        vl.textAlignment = .center
        vl.translatesAutoresizingMaskIntoConstraints = false
        let ll = UILabel()
        ll.text = label
        ll.setCaptionStyle()
        ll.textAlignment = .center
        ll.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(vl)
        v.addSubview(ll)
        NSLayoutConstraint.activate([
            vl.topAnchor.constraint(equalTo: v.topAnchor, constant: 8),
            vl.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            ll.topAnchor.constraint(equalTo: vl.bottomAnchor, constant: 4),
            ll.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            ll.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -8),
        ])
        return v
    }

    private func setupConstraints() {
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

            weightCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppUIStyle.paddingM),
            weightCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            weightCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),

            weightLabel.topAnchor.constraint(equalTo: weightCard.topAnchor, constant: AppUIStyle.paddingL),
            weightLabel.centerXAnchor.constraint(equalTo: weightCard.centerXAnchor),
            weightChangeLabel.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 4),
            weightChangeLabel.centerXAnchor.constraint(equalTo: weightCard.centerXAnchor),
            addWeightButton.topAnchor.constraint(equalTo: weightChangeLabel.bottomAnchor, constant: AppUIStyle.paddingM),
            addWeightButton.leadingAnchor.constraint(equalTo: weightCard.leadingAnchor, constant: AppUIStyle.paddingM),
            addWeightButton.trailingAnchor.constraint(equalTo: weightCard.trailingAnchor, constant: -AppUIStyle.paddingM),
            addWeightButton.heightAnchor.constraint(equalToConstant: 44),
            addWeightButton.bottomAnchor.constraint(equalTo: weightCard.bottomAnchor, constant: -AppUIStyle.paddingM),

            chartView.topAnchor.constraint(equalTo: weightCard.bottomAnchor, constant: AppUIStyle.paddingM),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),
            chartView.heightAnchor.constraint(equalToConstant: 180),

            fastingStatsCard.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: AppUIStyle.paddingM),
            fastingStatsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            fastingStatsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),

            predictionCard.topAnchor.constraint(equalTo: fastingStatsCard.bottomAnchor, constant: AppUIStyle.paddingM),
            predictionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            predictionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),
            predictionTitle.topAnchor.constraint(equalTo: predictionCard.topAnchor, constant: AppUIStyle.paddingM),
            predictionTitle.leadingAnchor.constraint(equalTo: predictionCard.leadingAnchor, constant: AppUIStyle.paddingM),
            predictionContent.topAnchor.constraint(equalTo: predictionTitle.bottomAnchor, constant: 8),
            predictionContent.leadingAnchor.constraint(equalTo: predictionCard.leadingAnchor, constant: AppUIStyle.paddingM),
            predictionContent.trailingAnchor.constraint(equalTo: predictionCard.trailingAnchor, constant: -AppUIStyle.paddingM),
            predictionContent.bottomAnchor.constraint(equalTo: predictionCard.bottomAnchor, constant: -AppUIStyle.paddingM),

            weeklyReportCard.topAnchor.constraint(equalTo: predictionCard.bottomAnchor, constant: AppUIStyle.paddingM),
            weeklyReportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            weeklyReportCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),
            weeklyReportCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppUIStyle.paddingXL),
        ])
    }

    // MARK: - Data
    private func loadData() {
        let ctx = CoreDataManager.shared.context

        // Weight records (last 30 days)
        let wReq: NSFetchRequest<WeightRecord> = WeightRecord.fetchRequest()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        wReq.predicate = NSPredicate(format: "recordDate >= %@", thirtyDaysAgo as NSDate)
        wReq.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: true)]
        weightRecords = (try? ctx.fetch(wReq)) ?? []

        // Fast records (last 7 days)
        let fReq: NSFetchRequest<FastRecord> = FastRecord.fetchRequest()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        fReq.predicate = NSPredicate(format: "startTime >= %@", sevenDaysAgo as NSDate)
        fastRecords = (try? ctx.fetch(fReq)) ?? []

        updateUI()
    }

    private func updateUI() {
        // Current weight
        if let latest = weightRecords.last {
            weightLabel.text = String(format: "%.1f kg", latest.weight)
            if weightRecords.count >= 2 {
                let prev = weightRecords[weightRecords.count - 2]
                let diff = latest.weight - prev.weight
                let sign = diff >= 0 ? "+" : ""
                weightChangeLabel.text = "\(sign)\(String(format: "%.1f", diff)) kg"
                weightChangeLabel.textColor = diff <= 0 ? AppColor.mainTint : AppColor.danger
            }
        } else {
            weightLabel.text = "--"
            weightChangeLabel.text = L("stats.no_weight_data")
        }

        // Chart
        chartView.update(records: weightRecords)

        // Prediction
        updatePrediction()

        // Weekly report
        updateWeeklyReport()
    }

    private func updatePrediction() {
        guard let profile = userProfile, let latest = weightRecords.last else {
            predictionContent.text = L("stats.prediction_no_data")
            return
        }
        let current = latest.weight
        let target = profile.targetWeight
        let diff = current - target
        guard diff > 0.5 else {
            predictionContent.text = L("stats.prediction_reached")
            return
        }
        // 防止 dailyDeficit 为 0 导致除以零崩溃
        let dailyDeficit = profile.calorieDeficit
        guard dailyDeficit > 0 else {
            predictionContent.text = L("stats.prediction_no_data")
            return
        }
        let daysNeeded = (diff * 7700) / dailyDeficit
        // 防止 daysNeeded 为 inf/NaN 导致 Int 转换崩溃
        guard daysNeeded.isFinite, daysNeeded > 0, daysNeeded < 3650 else {
            predictionContent.text = L("stats.prediction_no_data")
            return
        }
        let weeksNeeded = Int(ceil(daysNeeded / 7))
        let daysInt = Int(min(daysNeeded, 3650))
        let targetDate = Calendar.current.date(byAdding: .day, value: daysInt, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        predictionContent.text = String(format: L("stats.prediction_text"),
                                        String(format: "%.1f", diff),
                                        weeksNeeded,
                                        formatter.string(from: targetDate),
                                        Int(dailyDeficit))
    }

    private func updateWeeklyReport() {
        let weightChange = weightRecords.count >= 2 ? (weightRecords.last!.weight - weightRecords[max(0, weightRecords.count - 8)].weight) : 0
        AIFastPlanEngine.shared.generateWeeklyReport(
            fastRecords: fastRecords,
            weightChange: weightChange
        ) { [weak self] report in
            self?.weeklyReportContent.text = report
        }
    }

    // MARK: - Add Weight
    @objc private func addWeight() {
        let alert = UIAlertController(
            title: L("stats.log_weight"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "kg"
            tf.keyboardType = .decimalPad
            if let latest = self.weightRecords.last {
                tf.text = String(format: "%.1f", latest.weight)
            }
        }
        alert.addAction(UIAlertAction(title: L("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("common.save"), style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let weight = Double(text), weight > 0 else { return }
            self?.saveWeight(weight)
        })
        present(alert, animated: true)
    }

    private func saveWeight(_ weight: Double) {
        let ctx = CoreDataManager.shared.context
        let record = WeightRecord(context: ctx)
        record.weightID = UUID().uuidString
        record.recordDate = Calendar.current.startOfDay(for: Date())
        record.weight = weight
        record.createTime = Date()
        CoreDataManager.shared.save()

        // Update profile current weight
        UserProfileService.shared.update(weight: weight)
        loadData()
    }
}

// MARK: - WeightChartView (简单折线图)
class WeightChartView: UIView {

    private var records: [WeightRecord] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    func update(records: [WeightRecord]) {
        self.records = records
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard records.count >= 2 else {
            // Draw empty state
            let attrs: [NSAttributedString.Key: Any] = [
                .font: AppUIStyle.fontCaption,
                .foregroundColor: AppColor.textSub
            ]
            let text = L("stats.no_chart_data") as NSString
            let size = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (rect.width - size.width) / 2, y: (rect.height - size.height) / 2), withAttributes: attrs)
            return
        }

        let padding: CGFloat = 24
        let chartRect = rect.insetBy(dx: padding, dy: padding)
        let weights = records.map { $0.weight }
        let minW = (weights.min() ?? 50) - 1
        let maxW = (weights.max() ?? 100) + 1
        let range = maxW - minW
        let step = chartRect.width / CGFloat(records.count - 1)

        // Grid lines
        let gridPath = UIBezierPath()
        gridPath.lineWidth = 0.5
        AppColor.lineSeparator.setStroke()
        for i in 0...4 {
            let y = chartRect.minY + chartRect.height * CGFloat(i) / 4
            gridPath.move(to: CGPoint(x: chartRect.minX, y: y))
            gridPath.addLine(to: CGPoint(x: chartRect.maxX, y: y))
        }
        gridPath.stroke()

        // Line
        let linePath = UIBezierPath()
        linePath.lineWidth = 2
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        AppColor.mainTint.setStroke()

        for (i, record) in records.enumerated() {
            let x = chartRect.minX + CGFloat(i) * step
            let y = chartRect.maxY - CGFloat((record.weight - minW) / range) * chartRect.height
            if i == 0 { linePath.move(to: CGPoint(x: x, y: y)) }
            else { linePath.addLine(to: CGPoint(x: x, y: y)) }
        }
        linePath.stroke()

        // Dots
        for (i, record) in records.enumerated() {
            let x = chartRect.minX + CGFloat(i) * step
            let y = chartRect.maxY - CGFloat((record.weight - minW) / range) * chartRect.height
            let dotRect = CGRect(x: x - 4, y: y - 4, width: 8, height: 8)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            AppColor.mainTint.setFill()
            dotPath.fill()
        }
    }
}
