import SwiftUI

/// Native tabs reserve space for navigation and preserve each tab's stack.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        TabView(selection: $state.selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                NavigationStack(path: $state.homePath) { HomeView().withRoutes() }
            }
            Tab("Ledger", systemImage: "list.bullet", value: AppTab.ledger) { LedgerView() }
            Tab("Budget", systemImage: "chart.pie", value: AppTab.budget) { BudgetView() }
            Tab("Goals", systemImage: "target", value: AppTab.goals) { GoalsView() }
            Tab("Wealth", systemImage: "chart.line.uptrend.xyaxis", value: AppTab.wealth) {
                NavigationStack(path: $state.wealthPath) { WealthView().withRoutes() }
            }
        }
        .tint(Color.storAccent)
        .sheet(isPresented: $state.isAddingSpend) {
            AddSpendSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.sheet)
        }
    }
}

private extension View {
    func withRoutes() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .bills: BillsView()
            case .alerts: AlertsView()
            case .household: HouseholdView()
            case .recap: RecapView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview { MainTabView().environment(AppState()) }
