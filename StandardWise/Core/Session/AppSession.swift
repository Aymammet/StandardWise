import FirebaseAuth
import Foundation

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var currentUser: StandardWiseUser?
    @Published var loginErrorMessage: String?
    @Published var isLoggingIn = false

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func login(email: String, password: String) async {
        isLoggingIn = true
        loginErrorMessage = nil

        do {
            let user = try await LocalAuthService.authenticate(email: email, password: password)
            currentUser = user
        } catch {
            loginErrorMessage = loginMessage(for: error)
        }

        isLoggingIn = false
    }

    func logout() {
        try? LocalAuthService.logout()
        currentUser = nil
        loginErrorMessage = nil
    }

    private func loginMessage(for error: Error) -> String {
        guard let authError = AuthErrorCode(rawValue: (error as NSError).code) else {
            return "We could not log you in. Please try again."
        }

        switch authError.code {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword, .userNotFound, .invalidCredential:
            return "Email or password is incorrect."
        case .networkError:
            return "Please check your internet connection and try again."
        default:
            return "We could not log you in. Please try again."
        }
    }
}
