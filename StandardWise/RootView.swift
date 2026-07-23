import SwiftUI

struct RootView: View {
    @StateObject private var session = AppSession()
    @StateObject private var questionStore = QuestionStore()
    @StateObject private var standardStore = StandardStore()
    @StateObject private var feedbackStore = FeedbackStore()
    @StateObject private var answerAttemptStore = AnswerAttemptStore()

    var body: some View {
        if let user = session.currentUser {
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
        } else {
            LoginView(session: session)
        }
    }
}
