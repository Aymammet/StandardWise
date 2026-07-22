import Foundation

enum FeedbackStatus: String, Codable, CaseIterable, Identifiable {
    case new
    case reviewed
    case resolved

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .new:
            return "New"
        case .reviewed:
            return "Reviewed"
        case .resolved:
            return "Resolved"
        }
    }
}

struct QuestionFeedback: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let questionID: UUID
    var message: String
    var status: FeedbackStatus
    let createdAt: Date
}
