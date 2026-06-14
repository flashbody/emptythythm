import Foundation
import UserNotifications

// MARK: - 通知管理器
final class NotificationManager: NSObject {

    static let shared = NotificationManager()
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - 请求权限（用户点击功能时才调用）
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - 检查权限状态
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - 断食开始提醒
    func scheduleFastStartReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = L("notification.fast_start.title")
        content.body = L("notification.fast_start.body")
        content.sound = .default
        content.categoryIdentifier = "FAST_START"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(date.timeIntervalSinceNow, 1),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "fast_start_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 进食窗口开启提醒
    func scheduleEatWindowReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = L("notification.eat_window.title")
        content.body = L("notification.eat_window.body")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(date.timeIntervalSinceNow, 1),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "eat_window_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 进食窗口关闭预警（提前 30 分钟）
    func scheduleEatWindowCloseWarning(closingAt date: Date) {
        let warningDate = date.addingTimeInterval(-30 * 60)
        guard warningDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = L("notification.eat_close_warning.title")
        content.body = L("notification.eat_close_warning.body")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: warningDate.timeIntervalSinceNow,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "eat_close_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 每日 21:00 进度收尾提醒
    func scheduleDailyProgressReminder() {
        let content = UNMutableNotificationContent()
        content.title = L("notification.daily_progress.title")
        content.body = L("notification.daily_progress.body")
        content.sound = .default

        var components = DateComponents()
        components.hour = 21
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_progress",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 取消所有断食相关通知
    func cancelFastNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["fast_start", "eat_window", "eat_close"]
        )
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
