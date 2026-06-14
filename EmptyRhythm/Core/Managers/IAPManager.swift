import StoreKit

// MARK: - IAP 管理器（买断制 $3.99）
final class IAPManager: NSObject, ObservableObject {

    static let shared = IAPManager()
    private override init() { super.init() }

    let proProductID = "com.emptythythm.app.pro"
    private let proUnlockedKey = "er_pro_unlocked"

    var isProUnlocked: Bool {
        get { UserDefaults.standard.bool(forKey: proUnlockedKey) }
        set { UserDefaults.standard.set(newValue, forKey: proUnlockedKey) }
    }

    // MARK: - 购买
    @available(iOS 15.0, *)
    func purchase() async throws {
        guard let product = try await Product.products(for: [proProductID]).first else {
            throw IAPError.productNotFound
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                isProUnlocked = true
                await transaction.finish()
            case .unverified:
                throw IAPError.verificationFailed
            }
        case .userCancelled:
            throw IAPError.userCancelled
        case .pending:
            break
        @unknown default:
            break
        }
    }

    // MARK: - 恢复购买
    @available(iOS 15.0, *)
    func restore() async throws {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == proProductID {
                isProUnlocked = true
                await transaction.finish()
                return
            }
        }
    }

    // MARK: - 获取价格
    @available(iOS 15.0, *)
    func fetchPrice() async -> String? {
        guard let product = try? await Product.products(for: [proProductID]).first else { return nil }
        return product.displayPrice
    }
}

enum IAPError: LocalizedError {
    case productNotFound
    case verificationFailed
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .productNotFound:   return "Product not found"
        case .verificationFailed: return "Purchase verification failed"
        case .userCancelled:     return "Purchase cancelled"
        }
    }
}
