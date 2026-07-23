import Foundation

struct AnswerAttempt: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let questionID: UUID
    let subjectName: String
    let gradeName: String
    let standardCode: String
    let submittedAnswer: String
    let isCorrect: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        questionID: UUID,
        subjectName: String,
        gradeName: String,
        standardCode: String,
        submittedAnswer: String,
        isCorrect: Bool,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.questionID = questionID
        self.subjectName = subjectName
        self.gradeName = gradeName
        self.standardCode = standardCode
        self.submittedAnswer = submittedAnswer
        self.isCorrect = isCorrect
        self.createdAt = createdAt
    }
}

final class AnswerAttemptStore: ObservableObject {
    @Published private(set) var attempts: [AnswerAttempt] {
        didSet {
            LocalPersistence.save(attempts, forKey: storageKey)
        }
    }

    private let storageKey = "standardwise.answerAttempts"

    init(attempts: [AnswerAttempt] = []) {
        if let savedAttempts = LocalPersistence.load([AnswerAttempt].self, forKey: storageKey) {
            self.attempts = savedAttempts
        } else {
            self.attempts = attempts
            LocalPersistence.save(attempts, forKey: storageKey)
        }
    }

    func record(_ attempt: AnswerAttempt) {
        attempts.insert(attempt, at: 0)
    }

    func attempts(for userID: UUID) -> [AnswerAttempt] {
        attempts.filter { $0.userID == userID }
    }
}
