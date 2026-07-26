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

#Preview("Populated") {
    MainTabView()
        .environment(AppState())
}

#Preview("Empty State") {
    let appState: AppState = {
        let state = AppState()
        state.expenses = []
        state.previousMonthExpenses = 0
        state.savingsPots = []
        state.pensions = []
        state.isas = []
        state.financialPosition = FinancialPosition(
            monthlyIncome: state.householdNetMonthly,
            monthlyExpenses: 0,
            monthlySavings: 0
        )
        return state
    }()

    MainTabView()
        .environment(appState)
}
