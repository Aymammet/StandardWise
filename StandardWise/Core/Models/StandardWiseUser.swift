import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case admin
    case regular

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .admin:
            return "Admin"
        case .regular:
            return "Regular user"
        }
    }
}

struct StandardWiseUser: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var role: UserRole
    var createdAt: Date
    var lastActiveAt: Date?
}
