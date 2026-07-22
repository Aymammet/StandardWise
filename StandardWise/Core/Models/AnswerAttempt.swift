import Foundation

struct AnswerAttempt: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let questionID: UUID
    let submittedAnswer: String
    let isCorrect: Bool
    let createdAt: Date
}
