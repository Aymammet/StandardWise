import FirebaseCore
import SwiftUI

@main
struct StandardWiseApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
