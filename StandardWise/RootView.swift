import SwiftUI

struct RootView: View {
    @StateObject private var session = AppSession()
    @StateObject private var questionStore = QuestionStore()

    var body: some View {
        if let user = session.currentUser {
            switch user.role {
            case .admin:
                AdminDashboardView(user: user, questionStore: questionStore) {
                    session.logout()
                }
            case .regular:
                PracticeView(questionStore: questionStore) {
                    session.logout()
                }
            }
        } else {
            LoginView(session: session)
        }
    }
}
