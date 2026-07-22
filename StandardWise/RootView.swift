import SwiftUI

struct RootView: View {
    @StateObject private var session = AppSession()

    var body: some View {
        if let user = session.currentUser {
            switch user.role {
            case .admin:
                AdminDashboardView(user: user) {
                    session.logout()
                }
            case .regular:
                PracticeView {
                    session.logout()
                }
            }
        } else {
            LoginView(session: session)
        }
    }
}
