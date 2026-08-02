import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Foundation
import Security

enum LocalAuthService {
    private struct LocalCredential {
        let user: StandardWiseUser
        let password: String
    }

    private static let adminEmails: Set<String> = [
        "admin@standardwise.app"
    ]

    static var sampleUsers: [StandardWiseUser] {
        localCredentials.map(\.user)
    }

    static var modeTitle: String {
        switch authMode {
        case .local:
            return "Local"
        case .staging:
            return "Staging"
        }
    }

    static var loginHelpLines: [String] {
        switch authMode {
        case .local:
            return [
                "Admin: admin@standardwise.app / admin123",
                "Regular: student@standardwise.app / student123"
            ]
        case .staging:
            return [
                "Admin role: admin@standardwise.app",
                "Regular role: any other Firebase email/password user"
            ]
        }
    }

    private static var authMode: StandardWiseAuthMode {
        StandardWiseAuthMode.current
    }

    private static var localCredentials: [LocalCredential] {
        [
            LocalCredential(
                user: StandardWiseUser(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000301")!,
                    name: "Admin User",
                    email: "admin@standardwise.app",
                    role: .admin,
                    createdAt: Date(),
                    lastActiveAt: nil
                ),
                password: "admin123"
            ),
            LocalCredential(
                user: StandardWiseUser(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000302")!,
                    name: "Regular User",
                    email: "student@standardwise.app",
                    role: .regular,
                    createdAt: Date(),
                    lastActiveAt: nil
                ),
                password: "student123"
            )
        ]
    }

    static func authenticate(email: String, password: String) async throws -> StandardWiseUser {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if authMode == .local {
            guard let credential = localCredentials.first(where: { credential in
                credential.user.email.lowercased() == normalizedEmail
            }) else {
                throw AuthServiceError.noUsernameFound
            }

            guard credential.password == password else {
                throw AuthServiceError.wrongPassword
            }

            return credential.user
        }

        let usernameExists: Bool
        if adminEmails.contains(normalizedEmail) {
            usernameExists = true
        } else {
            usernameExists = (try? await FirebaseUserService.usernameExists(email: normalizedEmail)) ?? true
        }

        guard usernameExists else {
            throw AuthServiceError.noUsernameFound
        }

        let result: AuthDataResult
        do {
            result = try await signIn(email: normalizedEmail, password: password)
        } catch {
            if isMissingUsernameError(error) {
                throw AuthServiceError.noUsernameFound
            }

            if isInvalidCredentialsError(error) {
                throw AuthServiceError.wrongPassword
            }

            if isWrongPasswordError(error) {
                throw AuthServiceError.wrongPassword
            }

            throw error
        }

        let defaultRole: UserRole = adminEmails.contains(normalizedEmail) ? .admin : .regular
        return try await FirebaseUserService.userProfile(
            from: result.user,
            fallbackEmail: normalizedEmail,
            defaultRole: defaultRole
        )
    }

    static func register(email: String, password: String) async throws -> StandardWiseUser {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard authMode == .staging else {
            throw AuthServiceError.registrationUnavailable
        }

        let result: AuthDataResult
        do {
            result = try await createUser(email: normalizedEmail, password: password)
        } catch {
            if isEmailAlreadyInUseError(error) {
                throw AuthServiceError.accountAlreadyExists
            }

            if isWeakPasswordError(error) {
                throw AuthServiceError.weakPassword
            }

            throw error
        }

        return try await FirebaseUserService.createUserProfile(
            from: result.user,
            fallbackEmail: normalizedEmail,
            defaultRole: .regular
        )
    }

    static func authenticateWithApple(
        authorization: ASAuthorization,
        rawNonce: String
    ) async throws -> StandardWiseUser {
        guard authMode == .staging else {
            throw AuthServiceError.appleSignInUnavailable
        }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthServiceError.invalidAppleCredential
        }

        guard let identityToken = appleIDCredential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthServiceError.invalidAppleCredential
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: identityTokenString,
            rawNonce: rawNonce
        )

        let result = try await signIn(with: credential)
        let fallbackEmail = appleIDCredential.email
            ?? result.user.email
            ?? "apple-\(result.user.uid)@standardwise.local"

        return try await FirebaseUserService.userProfile(
            from: result.user,
            fallbackEmail: fallbackEmail,
            defaultRole: .regular
        )
    }

    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status).")
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < UInt8(charset.count) {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    static func sendPasswordReset(email: String) async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard authMode == .staging else {
            throw AuthServiceError.passwordResetUnavailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().sendPasswordReset(withEmail: normalizedEmail) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume()
            }
        }
    }

    static func logout() throws {
        try Auth.auth().signOut()
    }

    private static func signIn(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    continuation.resume(throwing: AuthServiceError.missingUser)
                    return
                }

                continuation.resume(returning: result)
            }
        }
    }

    private static func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    continuation.resume(throwing: AuthServiceError.missingUser)
                    return
                }

                continuation.resume(returning: result)
            }
        }
    }

    private static func createUser(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    continuation.resume(throwing: AuthServiceError.missingUser)
                    return
                }

                continuation.resume(returning: result)
            }
        }
    }

    private static func isMissingUsernameError(_ error: Error) -> Bool {
        AuthErrorCode(rawValue: (error as NSError).code)?.code == .userNotFound
    }

    private static func isWrongPasswordError(_ error: Error) -> Bool {
        AuthErrorCode(rawValue: (error as NSError).code)?.code == .wrongPassword
    }

    private static func isInvalidCredentialsError(_ error: Error) -> Bool {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code)?.code else {
            return false
        }

        return code == .invalidCredential
    }

    private static func isEmailAlreadyInUseError(_ error: Error) -> Bool {
        AuthErrorCode(rawValue: (error as NSError).code)?.code == .emailAlreadyInUse
    }

    private static func isWeakPasswordError(_ error: Error) -> Bool {
        AuthErrorCode(rawValue: (error as NSError).code)?.code == .weakPassword
    }
}

enum AuthServiceError: Error {
    case noUsernameFound
    case wrongPassword
    case invalidCredentials
    case missingUser
    case registrationUnavailable
    case passwordResetUnavailable
    case accountAlreadyExists
    case weakPassword
    case appleSignInUnavailable
    case invalidAppleCredential
}
