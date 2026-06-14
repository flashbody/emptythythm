import Foundation
import Combine

// MARK: - 断食计时器状态
enum FastTimerState {
    case idle           // 未开始
    case fasting        // 断食中
    case eating         // 进食窗口
    case completed      // 已完成
    case interrupted    // 已中断
}

// MARK: - 断食计时器管理器（核心）
final class FastTimerManager: ObservableObject {

    static let shared = FastTimerManager()
    private init() { restoreState() }

    // MARK: - 状态
    @Published private(set) var state: FastTimerState = .idle
    @Published private(set) var elapsedSeconds: TimeInterval = 0
    @Published private(set) var currentPlan: FastPlanModel?
    @Published private(set) var progress: Double = 0   // 0.0 - 1.0

    private var startDate: Date?
    private var timer: Timer?

    private let startDateKey = "er_fast_start_date"
    private let planIDKey = "er_fast_plan_id"
    private let stateKey = "er_fast_state"

    // MARK: - 开始断食
    func startFasting(plan: FastPlanModel) {
        let now = Date()
        startDate = now
        currentPlan = plan
        state = .fasting
        elapsedSeconds = 0

        // 持久化
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: startDateKey)
        UserDefaults.standard.set(plan.id, forKey: planIDKey)
        UserDefaults.standard.set("fasting", forKey: stateKey)

        startTimer()
        scheduleNotifications(plan: plan, startDate: now)
    }

    // MARK: - 结束断食（完成）
    func completeFasting() {
        stopTimer()
        state = .completed
        saveRecord(status: 1)
        clearPersistedState()
    }

    // MARK: - 中断断食
    func interruptFasting() {
        stopTimer()
        state = .interrupted
        saveRecord(status: 2)
        clearPersistedState()
    }

    // MARK: - 重置
    func reset() {
        stopTimer()
        state = .idle
        elapsedSeconds = 0
        progress = 0
        startDate = nil
        currentPlan = nil
        clearPersistedState()
    }

    // MARK: - 系统时间校准（App 回到前台时调用）
    func syncWithSystemTime() {
        guard state == .fasting, let start = startDate else { return }
        let elapsed = Date().timeIntervalSince(start)
        elapsedSeconds = elapsed

        if let plan = currentPlan {
            let targetSeconds = TimeInterval(plan.fastHour * 3600)
            progress = min(elapsed / targetSeconds, 1.0)

            if elapsed >= targetSeconds {
                completeFasting()
            }
        }
    }

    // MARK: - 剩余时间
    var remainingSeconds: TimeInterval {
        guard let plan = currentPlan else { return 0 }
        let target = TimeInterval(plan.fastHour * 3600)
        return max(target - elapsedSeconds, 0)
    }

    // MARK: - 格式化时间显示
    var elapsedTimeString: String { formatTime(elapsedSeconds) }
    var remainingTimeString: String { formatTime(remainingSeconds) }

    // MARK: - Private
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let start = startDate, let plan = currentPlan else { return }
        let elapsed = Date().timeIntervalSince(start)
        elapsedSeconds = elapsed
        let target = TimeInterval(plan.fastHour * 3600)
        progress = min(elapsed / target, 1.0)

        if elapsed >= target {
            completeFasting()
        }
    }

    private func scheduleNotifications(plan: FastPlanModel, startDate: Date) {
        let fastEndDate = startDate.addingTimeInterval(TimeInterval(plan.fastHour * 3600))
        NotificationManager.shared.scheduleEatWindowReminder(at: fastEndDate)

        if plan.eatHour > 0 {
            let eatEndDate = fastEndDate.addingTimeInterval(TimeInterval(plan.eatHour * 3600))
            NotificationManager.shared.scheduleEatWindowCloseWarning(closingAt: eatEndDate)
        }
    }

    private func saveRecord(status: Int16) {
        guard let start = startDate else { return }
        let context = CoreDataManager.shared.context
        let record = FastRecord(context: context)
        record.recordID = UUID().uuidString
        record.startTime = start
        record.endTime = Date()
        record.targetHours = Double(currentPlan?.fastHour ?? 16)
        record.actualHours = elapsedSeconds / 3600
        record.status = status
        record.createTime = Date()
        CoreDataManager.shared.save()
    }

    private func restoreState() {
        let savedState = UserDefaults.standard.string(forKey: stateKey)
        guard savedState == "fasting",
              let startTS = UserDefaults.standard.object(forKey: startDateKey) as? TimeInterval else { return }
        startDate = Date(timeIntervalSince1970: startTS)
        state = .fasting
        syncWithSystemTime()
        if state == .fasting { startTimer() }
    }

    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: startDateKey)
        UserDefaults.standard.removeObject(forKey: planIDKey)
        UserDefaults.standard.removeObject(forKey: stateKey)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
