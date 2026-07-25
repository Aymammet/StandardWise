import SwiftUI

struct RootView: View {
    @StateObject private var session = AppSession()
    @StateObject private var questionStore = QuestionStore()
    @StateObject private var standardStore = StandardStore()
    @StateObject private var feedbackStore = FeedbackStore()
    @StateObject private var answerAttemptStore = AnswerAttemptStore()

    var body: some View {
        if let user = session.currentUser {
            Group {
                switch user.role {
                case .admin:
                    AdminDashboardView(
                        user: user,
                        questionStore: questionStore,
                        standardStore: standardStore,
                        feedbackStore: feedbackStore,
                        answerAttemptStore: answerAttemptStore
                    ) {
                        session.logout()
                    }
                case .regular:
                    PracticeView(
                        user: user,
                        questionStore: questionStore,
                        standardStore: standardStore,
                        feedbackStore: feedbackStore,
                        answerAttemptStore: answerAttemptStore
                    ) {
                        session.logout()
                    }
                }
            }            
            .task(id: user.id) {
                await refreshFirebaseDataAfterLogin(for: user)
            }
        } else {
            LoginView(session: session)
        }
    }

    private func refreshFirebaseDataAfterLogin(for user: StandardWiseUser) async {
        await standardStore.refreshFromFirebaseIfNeeded()
        await questionStore.refreshFromFirebaseIfNeeded()

        // Feedback and answer-attempt reads are admin-only under the Firestore
        // security rules, so skip them for regular users to avoid guaranteed
        // permission-denied errors and misleading sync status messages.
        guard user.role == .admin else { return }

        await feedbackStore.refreshFromFirebaseIfNeeded()
        await answerAttemptStore.refreshFromFirebaseIfNeeded()
    }
}
