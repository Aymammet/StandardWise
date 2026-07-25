import CryptoKit
import FirebaseAuth
import FirebaseFirestore
import Foundation

enum FirebaseUserService {
    static func loadUsers() async throws -> [StandardWiseUser] {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .getDocuments()

        return snapshot.documents
            .compactMap { document in
                standardWiseUser(
                    from: document,
                    fallbackUID: (document.data()["firebaseUID"] as? String) ?? document.documentID,
                    fallbackEmail: document.documentID
                )
            }
            .sorted { first, second in
                first.email.localizedCaseInsensitiveCompare(second.email) == .orderedAscending
            }
    }

    static func usernameExists(email: String) async throws -> Bool {
        try await userDocument(forEmail: email) != nil
    }

    static func userProfile(
        from firebaseUser: FirebaseAuth.User,
        fallbackEmail: String,
        defaultRole: UserRole
    ) async throws -> StandardWiseUser {
        let email = (firebaseUser.email ?? fallbackEmail).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let fallbackProfile = fallbackUserProfile(
            from: firebaseUser,
            email: email,
            defaultRole: defaultRole
        )

        do {
            if let document = try await userDocument(forEmail: email),
               let profile = standardWiseUser(from: document, fallbackUID: firebaseUser.uid, fallbackEmail: email) {
                try? await updateLastActive(document: document, email: email, firebaseUser: firebaseUser)
                return profile
            }

            try await save(fallbackProfile, firebaseUID: firebaseUser.uid)
        } catch {
            return fallbackProfile
        }

        return fallbackProfile
    }

    private static func fallbackUserProfile(
        from firebaseUser: FirebaseAuth.User,
        email: String,
        defaultRole: UserRole
    ) -> StandardWiseUser {
        StandardWiseUser(
            id: stableUUID(from: firebaseUser.uid),
            name: defaultName(
                for: email,
                role: defaultRole,
                displayName: firebaseUser.displayName
            ),
            email: email,
            role: defaultRole,
            createdAt: firebaseUser.metadata.creationDate ?? Date(),
            lastActiveAt: firebaseUser.metadata.lastSignInDate
        )
    }

    private static func userDocument(forEmail email: String) async throws -> DocumentSnapshot? {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let directDocument = try await Firestore.firestore()
            .collection("users")
            .document(documentID(forEmail: normalizedEmail))
            .getDocument()

        if directDocument.exists {
            return directDocument
        }

        let querySnapshot = try await Firestore.firestore()
            .collection("users")
            .whereField("emailLowercase", isEqualTo: normalizedEmail)
            .limit(to: 1)
            .getDocuments()

        return querySnapshot.documents.first
    }

    private static func save(_ user: StandardWiseUser, firebaseUID: String) async throws {
        var data: [String: Any] = [
            "id": user.id.uuidString,
            "firebaseUID": firebaseUID,
            "name": user.name,
            "email": user.email,
            "emailLowercase": user.email.lowercased(),
            "role": user.role.rawValue,
            "createdAt": Timestamp(date: user.createdAt),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let lastActiveAt = user.lastActiveAt {
            data["lastActiveAt"] = Timestamp(date: lastActiveAt)
        }

        try await Firestore.firestore()
            .collection("users")
            .document(documentID(forEmail: user.email))
            .setData(data, merge: true)
    }

    private static func updateLastActive(
        document: DocumentSnapshot,
        email: String,
        firebaseUser: FirebaseAuth.User
    ) async throws {
        // Write to the document that was actually found. Writing to
        // users/{email} could create a partial duplicate profile when the
        // existing document uses a different document ID.
        try await document.reference
            .setData(
                [
                    "firebaseUID": firebaseUser.uid,
                    "email": email,
                    "emailLowercase": email.lowercased(),
                    "lastActiveAt": Timestamp(date: firebaseUser.metadata.lastSignInDate ?? Date()),
                    "updatedAt": FieldValue.serverTimestamp()
                ],
                merge: true
            )
    }

    private static func standardWiseUser(
        from document: DocumentSnapshot,
        fallbackUID: String,
        fallbackEmail: String
    ) -> StandardWiseUser? {
        guard let data = document.data() else { return nil }

        let email = (data["emailLowercase"] as? String)
            ?? (data["email"] as? String)?.lowercased()
            ?? fallbackEmail
        let roleValue = data["role"] as? String
        let role = roleValue.flatMap(UserRole.init(rawValue:)) ?? .regular
        let name = (data["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let idString = data["id"] as? String

        return StandardWiseUser(
            id: idString.flatMap(UUID.init(uuidString:)) ?? stableUUID(from: fallbackUID),
            name: name?.isEmpty == false ? name! : defaultName(for: email, role: role, displayName: nil),
            email: email,
            role: role,
            createdAt: dateValue(from: data["createdAt"]) ?? Date(),
            lastActiveAt: dateValue(from: data["lastActiveAt"])
        )
    }

    private static func documentID(forEmail email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func dateValue(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        return value as? Date
    }

    private static func defaultName(for email: String, role: UserRole, displayName: String?) -> String {
        let trimmedDisplayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDisplayName?.isEmpty == false {
            return trimmedDisplayName!
        }

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
