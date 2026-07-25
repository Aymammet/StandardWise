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

@MainActor
final class AnswerAttemptStore: ObservableObject {
    @Published private(set) var attempts: [AnswerAttempt] {
        didSet {
            LocalPersistence.save(attempts, forKey: storageKey)
        }
    }
    @Published private(set) var syncStatusMessage: String?

    private let storageKey = "standardwise.answerAttempts"
    private let usesFirebaseAttempts = StandardWiseAuthMode.current == .staging

    init(attempts: [AnswerAttempt] = []) {
        if let savedAttempts = LocalPersistence.load([AnswerAttempt].self, forKey: storageKey) {
            self.attempts = savedAttempts
        } else {
            self.attempts = attempts
            LocalPersistence.save(attempts, forKey: storageKey)
        }

        // Firebase answer-attempt reads are admin-only under the Firestore
        // security rules, so loading happens after login via
        // refreshFromFirebaseIfNeeded instead of at init for every user.
    }

    func record(_ attempt: AnswerAttempt) {
        attempts.insert(attempt, at: 0)
        syncAttemptToFirebase(attempt)
    }

    func attempts(for userID: UUID) -> [AnswerAttempt] {
        attempts.filter { $0.userID == userID }
    }

    func refreshFromFirebaseIfNeeded() async {
        guard usesFirebaseAttempts else { return }
        await loadFirebaseAttempts()
    }

    private func loadFirebaseAttempts() async {
        do {
            let firebaseAttempts = try await FirebaseAnswerAttemptService.loadAttempts()
            if !firebaseAttempts.isEmpty {
                attempts = firebaseAttempts
            }
            syncStatusMessage = "Answer attempts are synced with Firebase."
        } catch {
            syncStatusMessage = "Using local answer attempts because Firebase is unavailable."
        }
    }

    private func syncAttemptToFirebase(_ attempt: AnswerAttempt) {
        guard usesFirebaseAttempts else { return }

        Task {
            do {
                try await FirebaseAnswerAttemptService.saveAttempt(attempt)
                syncStatusMessage = "Answer attempt saved to Firebase."
            } catch {
                syncStatusMessage = "Answer attempt saved locally. Firebase sync failed."
            }
        }
    }
}
