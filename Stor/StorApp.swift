import SwiftUI

@main
struct StorApp: App {
    @State private var appState = AppState()

    init() {
        Typography.configureNavigationBar()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated && appState.hasHousehold {
                    MainTabView()
                } else {
                    WelcomeView()
                }
            }
            .environment(appState)
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
        }
    }
}
