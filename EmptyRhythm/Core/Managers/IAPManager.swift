import Foundation

// MARK: - IAP Manager（已禁用，App 改为付费下载模式）
// App 定价：$3.99 付费下载，无内购
final class IAPManager {
    static let shared = IAPManager()
    private init() {}

    // 付费下载模式：所有用户均视为已解锁
    var isProUnlocked: Bool { true }
}
