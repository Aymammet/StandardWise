import CryptoKit
import FirebaseAuth
import Foundation

enum LocalAuthService {
    private static let adminEmails: Set<String> = [
        "admin@standardwise.app"
    ]

    static var sampleUsers: [StandardWiseUser] {
        [
            StandardWiseUser(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000301")!,
                name: "Admin User",
                email: "admin@standardwise.app",
                role: .admin,
                createdAt: Date(),
                lastActiveAt: nil
            ),
            StandardWiseUser(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000302")!,
                name: "Regular User",
                email: "student@standardwise.app",
                role: .regular,
                createdAt: Date(),
                lastActiveAt: nil
            )
        ]
    }

    static func authenticate(email: String, password: String) async throws -> StandardWiseUser {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let result = try await signIn(email: normalizedEmail, password: password)

        return userProfile(from: result.user, fallbackEmail: normalizedEmail)
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

    private static func userProfile(from firebaseUser: FirebaseAuth.User, fallbackEmail: String) -> StandardWiseUser {
        let email = (firebaseUser.email ?? fallbackEmail).lowercased()
        let role: UserRole = adminEmails.contains(email) ? .admin : .regular
        let displayName = firebaseUser.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = displayName?.isEmpty == false ? displayName! : defaultName(for: email, role: role)

        return StandardWiseUser(
            id: stableUUID(from: firebaseUser.uid),
            name: name,
            email: email,
            role: role,
            createdAt: firebaseUser.metadata.creationDate ?? Date(),
            lastActiveAt: firebaseUser.metadata.lastSignInDate
        )
    }

    private static func defaultName(for email: String, role: UserRole) -> String {
        if role == .admin {
            return "Admin User"
        }

        let localPart = email.split(separator: "@").first.map(String.init) ?? "Student"
        return localPart
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private static func stableUUID(from value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80

        let uuid = (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )

        return UUID(uuid: uuid)
    }
}

private enum AuthServiceError: Error {
    case missingUser
}
