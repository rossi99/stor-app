import SwiftUI

@main
struct StorApp: App {
    @State private var appState = AppState(backend: BackendConfig.live())

    init() {
        Typography.configureNavigationBar()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.isAuthenticated {
                    AuthView()
                } else if appState.loadState == .loading {
                    ProgressView("Loading your household")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.storBackground)
                } else if appState.loadState == .failed {
                    ContentUnavailableView {
                        Label("Couldn’t load your household", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text("Check your connection and try again.")
                    } actions: {
                        Button("Try again") { Task { await appState.loadHousehold() } }
                    }
                    .background(Color.storBackground)
                } else if appState.hasCompletedSetup {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .alert("Not saved", isPresented: Binding(
                get: { appState.syncError != nil },
                set: { if !$0 { appState.syncError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(appState.syncError ?? "")
            }
            .environment(appState)
            .environment(\.money, appState.money)
            .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedSetup)
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
            .preferredColorScheme(.light)
        }
    }
}
