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
                if !appState.isAuthenticated {
                    AuthView()
                } else if appState.hasCompletedSetup {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(appState)
            .environment(\.money, appState.money)
            .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedSetup)
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
            .preferredColorScheme(.light)
        }
    }
}
