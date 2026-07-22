import Foundation

enum LocalAuthService {
    private struct LocalCredential {
        let user: StandardWiseUser
        let password: String
    }

    private static let credentials: [LocalCredential] = [
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

    static var sampleUsers: [StandardWiseUser] {
        credentials.map(\.user)
    }

    static func authenticate(email: String, password: String) -> StandardWiseUser? {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return credentials.first { credential in
            credential.user.email.lowercased() == normalizedEmail && credential.password == password
        }?.user
    }
}
