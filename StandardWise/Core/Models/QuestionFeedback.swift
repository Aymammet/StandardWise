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

@MainActor
final class FeedbackStore: ObservableObject {
    @Published private(set) var feedbackItems: [QuestionFeedback] {
        didSet {
            LocalPersistence.save(feedbackItems, forKey: storageKey)
        }
    }
    @Published private(set) var syncStatusMessage: String?

    private let storageKey = "standardwise.feedback"
    private let usesFirebaseFeedback = StandardWiseAuthMode.current == .staging

    init(feedbackItems: [QuestionFeedback] = []) {
        if let savedFeedback = LocalPersistence.load([QuestionFeedback].self, forKey: storageKey) {
            self.feedbackItems = savedFeedback
        } else {
            self.feedbackItems = feedbackItems
            LocalPersistence.save(feedbackItems, forKey: storageKey)
        }

        if usesFirebaseFeedback {
            syncStatusMessage = "Syncing feedback from Firebase..."
            Task {
                await loadFirebaseFeedback()
            }
        }
    }

    func submitFeedback(userID: UUID, questionID: UUID, message: String) {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        let feedback = QuestionFeedback(
            userID: userID,
            questionID: questionID,
            message: trimmedMessage
        )
        feedbackItems.insert(feedback, at: 0)
        syncFeedbackToFirebase(feedback)
    }

    func updateStatus(for feedback: QuestionFeedback, status: FeedbackStatus) {
        guard let index = feedbackItems.firstIndex(where: { $0.id == feedback.id }) else { return }

        feedbackItems[index].status = status
        syncFeedbackToFirebase(feedbackItems[index])
    }

    func refreshFromFirebaseIfNeeded() async {
        guard usesFirebaseFeedback else { return }
        await loadFirebaseFeedback()
    }

    private func loadFirebaseFeedback() async {
        do {
            let firebaseFeedback = try await FirebaseFeedbackService.loadFeedback()
            if !firebaseFeedback.isEmpty {
                feedbackItems = firebaseFeedback
            }
            syncStatusMessage = "Feedback is synced with Firebase."
        } catch {
            syncStatusMessage = "Using local feedback because Firebase is unavailable."
        }
    }

    private func syncFeedbackToFirebase(_ feedback: QuestionFeedback) {
        guard usesFirebaseFeedback else { return }

        Task {
            do {
                try await FirebaseFeedbackService.saveFeedback(feedback)
                syncStatusMessage = "Feedback saved to Firebase."
            } catch {
                syncStatusMessage = "Feedback saved locally. Firebase sync failed."
            }
        }
    }
}
