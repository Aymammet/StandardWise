import FirebaseAuth
import Foundation

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var currentUser: StandardWiseUser?
    @Published var loginErrorMessage: String?
    @Published var authInfoMessage: String?
    @Published var isLoggingIn = false
    @Published var isRegistering = false
    @Published var isSendingPasswordReset = false

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func login(email: String, password: String) async {
        isLoggingIn = true
        loginErrorMessage = nil
        authInfoMessage = nil

        do {
            let user = try await LocalAuthService.authenticate(email: email, password: password)
            currentUser = user
        } catch {
            loginErrorMessage = loginMessage(for: error)
        }

        isLoggingIn = false
    }

    func register(email: String, password: String) async {
        isRegistering = true
        loginErrorMessage = nil
        authInfoMessage = nil

        do {
            let user = try await LocalAuthService.register(email: email, password: password)
            currentUser = user
        } catch {
            loginErrorMessage = loginMessage(for: error)
        }

        isRegistering = false
    }

    func sendPasswordReset(email: String) async {
        isSendingPasswordReset = true
        loginErrorMessage = nil
        authInfoMessage = nil

        do {
            try await LocalAuthService.sendPasswordReset(email: email)
            authInfoMessage = "Password reset email sent. Please check your inbox."
        } catch {
            loginErrorMessage = loginMessage(for: error)
        }

        isSendingPasswordReset = false
    }

    func logout() {
        try? LocalAuthService.logout()
        currentUser = nil
        loginErrorMessage = nil
        authInfoMessage = nil
    }

    private func loginMessage(for error: Error) -> String {
        if let authServiceError = error as? AuthServiceError {
            switch authServiceError {
            case .noUsernameFound:
                return "No username exists."
            case .wrongPassword:
                return "Wrong password."
            case .invalidCredentials:
                return "Wrong password."
            case .missingUser:
                return "We could not find a signed-in user. Please try again."
            case .registrationUnavailable:
                return "Registration is available in Staging mode only."
            case .passwordResetUnavailable:
                return "Password reset is available in Staging mode only."
            case .accountAlreadyExists:
                return "An account already exists for this email."
            case .weakPassword:
                return "Password should be at least 6 characters."
            }
        }

        let nsError = error as NSError

        guard let authError = AuthErrorCode(rawValue: nsError.code) else {
            return nsError.localizedDescription
        }

        switch authError.code {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword:
            return "Wrong password."
        case .invalidCredential:
            return "Wrong password."
        case .userNotFound:
            return "No username exists."
        case .operationNotAllowed:
            return "Email/password login is not enabled in Firebase."
        case .emailAlreadyInUse:
            return "An account already exists for this email."
        case .weakPassword:
            return "Password should be at least 6 characters."
        case .userDisabled:
            return "This Firebase user account is disabled."
        case .tooManyRequests:
            return "Too many login attempts. Please wait and try again."
        case .networkError:
            return "Please check your internet connection and try again."
        case .appNotAuthorized:
            return "This app is not authorized for Firebase Authentication. Check the Firebase iOS app bundle ID."
        case .invalidAPIKey:
            return "Firebase API key is not valid for this app."
        case .keychainError:
            return "The app could not access the iOS Keychain. Please rebuild the app and try again."
        case .internalError:
            return "Firebase had an internal login error. Please try again."
        default:
            return nsError.localizedDescription
        }
    }
}
