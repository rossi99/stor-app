import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "square.grid.2x2.fill") {
                DashboardView()
            }

            Tab("Savings", systemImage: "chart.bar.fill") {
                SavingsView()
            }

            Tab("Forecast", systemImage: "chart.line.uptrend.xyaxis") {
                ForecastView()
            }
        }
        .tint(Color.storAccent)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}

#Preview("Dark") {
    MainTabView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
