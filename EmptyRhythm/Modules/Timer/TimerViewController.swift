import UIKit
import CoreData

// MARK: - 计时器主页面
class TimerViewController: UIViewController {

    // MARK: - UI 组件
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // 顶部状态卡片
    private let statusCard = UIView()
    private let statusLabel = UILabel()
    private let planNameLabel = UILabel()

    // 环形进度计时器
    private let timerContainerView = UIView()
    private let ringProgressView = RingProgressView()
    private let elapsedTimeLabel = UILabel()
    private let elapsedDescLabel = UILabel()
    private let remainingTimeLabel = UILabel()
    private let remainingDescLabel = UILabel()

    // 操作按钮
    private let startButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let buttonStack = UIStackView()

    // 今日统计卡片
    private let statsCard = UIView()
    private let statsTitle = UILabel()
    private let statsStack = UIStackView()

    // 统计数字 label（需要持久引用以便更新）
    private let streakValueLabel = UILabel()
    private let completedValueLabel = UILabel()
    private let weightValueLabel = UILabel()

    // AI 快捷入口
    private let aiQuickButton = UIButton(type: .system)

    // MARK: - 数据
    private let timerManager = FastTimerManager.shared
    private var displayLink: CADisplayLink?

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindTimerManager()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timerManager.syncWithSystemTime()
        updateUI()
        loadStatsData()
    }

    // MARK: - 加载统计数据
    private func loadStatsData() {
        let ctx = CoreDataManager.shared.context
        let today = Calendar.current.startOfDay(for: Date())

        // 1. 今日完成次数
        let completedReq: NSFetchRequest<FastRecord> = FastRecord.fetchRequest()
        completedReq.predicate = NSPredicate(
            format: "startTime >= %@ AND status == 1", today as NSDate
        )
        let todayCompleted = (try? ctx.count(for: completedReq)) ?? 0
        completedValueLabel.text = "\(todayCompleted)"

        // 2. 连续断食天数（streak）
        let streakDays = calculateStreak(ctx: ctx)
        streakValueLabel.text = "\(streakDays)"

        // 3. 最新体重
        let weightReq: NSFetchRequest<WeightRecord> = WeightRecord.fetchRequest()
        weightReq.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: false)]
        weightReq.fetchLimit = 1
        if let latest = try? ctx.fetch(weightReq).first {
            weightValueLabel.text = String(format: "%.1f", latest.weight)
        } else {
            weightValueLabel.text = "--"
        }
    }

    private func calculateStreak(ctx: NSManagedObjectContext) -> Int {
        let req: NSFetchRequest<FastRecord> = FastRecord.fetchRequest()
        req.predicate = NSPredicate(format: "status == 1")
        req.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        guard let records = try? ctx.fetch(req), !records.isEmpty else { return 0 }

        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())
        let cal = Calendar.current

        for record in records {
            guard let startTime = record.startTime else { continue }
            let recordDay = cal.startOfDay(for: startTime)
            if recordDay == checkDate {
                streak += 1
                checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
            } else if recordDay < checkDate {
                break
            }
        }
        return streak
    }

    // MARK: - UI 搭建
    private func setupUI() {
        view.setPageBackground()
        title = L("tab.timer")
        navigationController?.navigationBar.prefersLargeTitles = true

        // AI 快捷按钮（右上角）
        aiQuickButton.setImage(UIImage(systemName: "sparkles"), for: .normal)
        aiQuickButton.tintColor = AppColor.aiBlue
        aiQuickButton.addTarget(self, action: #selector(openAIAssistant), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: aiQuickButton)

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 状态卡片
        statusCard.setCardStyle()
        statusCard.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.setCaptionStyle()
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        planNameLabel.setTitleStyle()
        planNameLabel.textAlignment = .center
        planNameLabel.translatesAutoresizingMaskIntoConstraints = false

        statusCard.addSubview(statusLabel)
        statusCard.addSubview(planNameLabel)
        contentView.addSubview(statusCard)

        // 环形进度
        timerContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timerContainerView)

        ringProgressView.translatesAutoresizingMaskIntoConstraints = false
        ringProgressView.progressColor = AppColor.mainTint
        ringProgressView.trackColor = AppColor.lineSeparator
        ringProgressView.lineWidth = 12
        timerContainerView.addSubview(ringProgressView)

        elapsedTimeLabel.font = AppUIStyle.fontMono
        elapsedTimeLabel.textColor = AppColor.textMain
        elapsedTimeLabel.textAlignment = .center
        elapsedTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        elapsedDescLabel.setCaptionStyle()
        elapsedDescLabel.textAlignment = .center
        elapsedDescLabel.text = L("timer.elapsed")
        elapsedDescLabel.translatesAutoresizingMaskIntoConstraints = false

        remainingTimeLabel.font = AppUIStyle.fontMonoSmall
        remainingTimeLabel.textColor = AppColor.textSub
        remainingTimeLabel.textAlignment = .center
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        remainingDescLabel.setCaptionStyle()
        remainingDescLabel.textAlignment = .center
        remainingDescLabel.text = L("timer.remaining")
        remainingDescLabel.translatesAutoresizingMaskIntoConstraints = false

        timerContainerView.addSubview(elapsedTimeLabel)
        timerContainerView.addSubview(elapsedDescLabel)
        timerContainerView.addSubview(remainingTimeLabel)
        timerContainerView.addSubview(remainingDescLabel)

        // 操作按钮
        startButton.setTitle(L("timer.start"), for: .normal)
        startButton.setMainStyle()
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        stopButton.setTitle(L("timer.stop"), for: .normal)
        stopButton.setDestructiveStyle()
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(startButton)
        buttonStack.addArrangedSubview(stopButton)
        contentView.addSubview(buttonStack)

        // 今日统计卡片
        statsCard.setCardStyle()
        statsCard.translatesAutoresizingMaskIntoConstraints = false

        statsTitle.setSubTitleStyle()
        statsTitle.text = L("timer.today_stats")
        statsTitle.translatesAutoresizingMaskIntoConstraints = false

        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 8
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        // 使用持久引用构建统计 item
        let streakItem = makeStatItem(valueLabel: streakValueLabel, label: L("stats.streak"), color: AppColor.mainTint)
        let completedItem = makeStatItem(valueLabel: completedValueLabel, label: L("stats.completed"), color: AppColor.aiBlue)
        let weightItem = makeStatItem(valueLabel: weightValueLabel, label: L("stats.weight"), color: AppColor.warningOrange)
        statsStack.addArrangedSubview(streakItem)
        statsStack.addArrangedSubview(completedItem)
        statsStack.addArrangedSubview(weightItem)

        statsCard.addSubview(statsTitle)
        statsCard.addSubview(statsStack)
        contentView.addSubview(statsCard)
    }

    private func makeStatItem(valueLabel: UILabel, label: String, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.text = "--"
        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = label
        descLabel.setCaptionStyle()
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(valueLabel)
        container.addSubview(descLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            descLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            descLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        return container
    }

    // MARK: - 约束
    private func setupConstraints() {
        let ringSize: CGFloat = 280

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // 不设置 contentView.bottom = scrollView.bottom，让内容自动撑开高度

            // 状态卡片
            statusCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppUIStyle.paddingM),
            statusCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            statusCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),

            statusLabel.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: AppUIStyle.paddingM),
            statusLabel.centerXAnchor.constraint(equalTo: statusCard.centerXAnchor),
            planNameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            planNameLabel.centerXAnchor.constraint(equalTo: statusCard.centerXAnchor),
            planNameLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -AppUIStyle.paddingM),

            // 环形计时器
            timerContainerView.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: AppUIStyle.paddingL),
            timerContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timerContainerView.widthAnchor.constraint(equalToConstant: ringSize),
            timerContainerView.heightAnchor.constraint(equalToConstant: ringSize),

            ringProgressView.topAnchor.constraint(equalTo: timerContainerView.topAnchor),
            ringProgressView.leadingAnchor.constraint(equalTo: timerContainerView.leadingAnchor),
            ringProgressView.trailingAnchor.constraint(equalTo: timerContainerView.trailingAnchor),
            ringProgressView.bottomAnchor.constraint(equalTo: timerContainerView.bottomAnchor),

            elapsedTimeLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            elapsedTimeLabel.centerYAnchor.constraint(equalTo: timerContainerView.centerYAnchor, constant: -16),

            elapsedDescLabel.topAnchor.constraint(equalTo: elapsedTimeLabel.bottomAnchor, constant: 2),
            elapsedDescLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),

            remainingTimeLabel.topAnchor.constraint(equalTo: elapsedDescLabel.bottomAnchor, constant: 12),
            remainingTimeLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),

            remainingDescLabel.topAnchor.constraint(equalTo: remainingTimeLabel.bottomAnchor, constant: 2),
            remainingDescLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),

            // 操作按钮
            buttonStack.topAnchor.constraint(equalTo: timerContainerView.bottomAnchor, constant: AppUIStyle.paddingL),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),
            buttonStack.heightAnchor.constraint(equalToConstant: 52),

            // 统计卡片
            statsCard.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: AppUIStyle.paddingL),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppUIStyle.paddingM),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppUIStyle.paddingM),
            statsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100), // tabBar + 安全区域

            statsTitle.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: AppUIStyle.paddingM),
            statsTitle.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: AppUIStyle.paddingM),

            statsStack.topAnchor.constraint(equalTo: statsTitle.bottomAnchor, constant: AppUIStyle.paddingS),
            statsStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: AppUIStyle.paddingS),
            statsStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -AppUIStyle.paddingS),
            statsStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -AppUIStyle.paddingS),
        ])
    }

    // MARK: - 绑定
    private func bindTimerManager() {
        // 使用 Timer 轮询更新（UIKit 兼容方式）
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.preferredFramesPerSecond = 4  // 每秒 4 次足够
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateDisplay() {
        updateUI()
    }

    // MARK: - UI 更新
    private func updateUI() {
        let state = timerManager.state

        switch state {
        case .idle:
            statusLabel.text = L("timer.status.idle")
            planNameLabel.text = timerManager.currentPlan?.displayName ?? L("timer.no_plan")
            elapsedTimeLabel.text = "00:00:00"
            remainingTimeLabel.text = "--:--:--"
            ringProgressView.progress = 0
            startButton.isHidden = false
            stopButton.isHidden = true

        case .fasting:
            statusLabel.text = L("timer.status.fasting")
            planNameLabel.text = timerManager.currentPlan?.displayName ?? ""
            elapsedTimeLabel.text = timerManager.elapsedTimeString
            remainingTimeLabel.text = timerManager.remainingTimeString
            ringProgressView.progress = timerManager.progress
            startButton.isHidden = true
            stopButton.isHidden = false

        case .eating:
            statusLabel.text = L("timer.status.eating")
            planNameLabel.text = timerManager.currentPlan?.displayName ?? ""
            elapsedTimeLabel.text = timerManager.elapsedTimeString
            remainingTimeLabel.text = timerManager.remainingTimeString
            ringProgressView.progress = timerManager.progress
            ringProgressView.progressColor = AppColor.warningOrange
            startButton.isHidden = true
            stopButton.isHidden = false

        case .completed:
            statusLabel.text = L("timer.status.completed")
            planNameLabel.text = L("timer.completed_today")
            ringProgressView.progress = 1.0
            startButton.setTitle(L("timer.start_again"), for: .normal)
            startButton.isHidden = false
            stopButton.isHidden = true

        case .interrupted:
            statusLabel.text = L("timer.status.interrupted")
            startButton.setTitle(L("timer.restart"), for: .normal)
            startButton.isHidden = false
            stopButton.isHidden = true
        }
    }

    // MARK: - 按钮事件
    @objc private func startTapped() {
        // 防重复点击：已在断食中直接返回
        guard timerManager.state == .idle || timerManager.state == .completed || timerManager.state == .interrupted else { return }
        startButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startButton.isEnabled = true
        }
        // 检查是否有用户档案
        guard UserProfileService.shared.hasProfile else {
            let vc = ProfileSetupViewController()
            vc.onComplete = { [weak self] in
                self?.showPlanSelection()
            }
            present(UINavigationController(rootViewController: vc), animated: true)
            return
        }
        showPlanSelection()
    }

    private func showPlanSelection() {
        let vc = FastPlanSelectionViewController()
        vc.onPlanSelected = { [weak self] plan in
            self?.timerManager.startFasting(plan: plan)
            self?.updateUI()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func stopTapped() {
        let alert = UIAlertController(
            title: L("timer.stop.title"),
            message: L("timer.stop.message"),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: L("timer.stop.complete"), style: .default) { [weak self] _ in
            self?.timerManager.completeFasting()
        })
        alert.addAction(UIAlertAction(title: L("timer.stop.interrupt"), style: .destructive) { [weak self] _ in
            self?.timerManager.interruptFasting()
        })
        alert.addAction(UIAlertAction(title: L("common.cancel"), style: .cancel))
        present(alert, animated: true)
    }

    @objc private func openAIAssistant() {
        tabBarController?.selectedIndex = 3
    }

    deinit {
        displayLink?.invalidate()
    }
}
