import Foundation

final class AppSession: ObservableObject {
    @Published private(set) var currentUser: StandardWiseUser?
    @Published var loginErrorMessage: String?
    @Published var isLoggingIn = false

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func login(email: String, password: String) {
        isLoggingIn = true
        loginErrorMessage = nil

        if let user = LocalAuthService.authenticate(email: email, password: password) {
            currentUser = user
        } else {
            loginErrorMessage = "Email or password is incorrect."
        }

        isLoggingIn = false
    }

    func logout() {
        currentUser = nil
        loginErrorMessage = nil
    }
}
