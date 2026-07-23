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

    init(
        id: UUID = UUID(),
        userID: UUID,
        questionID: UUID,
        message: String,
        status: FeedbackStatus = .new,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.questionID = questionID
        self.message = message
        self.status = status
        self.createdAt = createdAt
    }
}

final class FeedbackStore: ObservableObject {
    @Published private(set) var feedbackItems: [QuestionFeedback] {
        didSet {
            LocalPersistence.save(feedbackItems, forKey: storageKey)
        }
    }

    private let storageKey = "standardwise.feedback"

    init(feedbackItems: [QuestionFeedback] = []) {
        if let savedFeedback = LocalPersistence.load([QuestionFeedback].self, forKey: storageKey) {
            self.feedbackItems = savedFeedback
        } else {
            self.feedbackItems = feedbackItems
            LocalPersistence.save(feedbackItems, forKey: storageKey)
        }
    }

    func submitFeedback(userID: UUID, questionID: UUID, message: String) {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        feedbackItems.insert(
            QuestionFeedback(
                userID: userID,
                questionID: questionID,
                message: trimmedMessage
            ),
            at: 0
        )
    }

    func updateStatus(for feedback: QuestionFeedback, status: FeedbackStatus) {
        guard let index = feedbackItems.firstIndex(where: { $0.id == feedback.id }) else { return }

        feedbackItems[index].status = status
    }
}
