import Foundation
import AuthenticationServices

// MARK: - 认证管理器（Sign in with Apple）
final class AuthManager: NSObject {

    static let shared = AuthManager()
    private override init() {}

    private let userIDKey = "er_apple_user_id"
    private let loggedInKey = "er_is_logged_in"

    var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: loggedInKey)
    }

    var currentUserID: String? {
        UserDefaults.standard.string(forKey: userIDKey)
    }

    // MARK: - 发起 Apple 登录
    func signIn(presentingVC: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.signInCompletion = completion
        self.presentingVC = presentingVC
        controller.performRequests()
    }

    // MARK: - 登出
    func signOut() {
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.set(false, forKey: loggedInKey)
    }

    // MARK: - 验证凭证状态
    func checkCredentialState(completion: @escaping (ASAuthorizationAppleIDProvider.CredentialState) -> Void) {
        guard let userID = currentUserID else {
            completion(.notFound)
            return
        }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
            DispatchQueue.main.async { completion(state) }
        }
    }

    // MARK: - Private
    private var signInCompletion: ((Result<String, Error>) -> Void)?
    private weak var presentingVC: UIViewController?
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthManager: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        let userID = credential.user
        UserDefaults.standard.set(userID, forKey: userIDKey)
        UserDefaults.standard.set(true, forKey: loggedInKey)
        signInCompletion?(.success(userID))
        signInCompletion = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        signInCompletion?(.failure(error))
        signInCompletion = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentingVC?.view.window ?? UIWindow()
    }
}
