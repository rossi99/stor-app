import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var showExpenseList = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.md) {

                    PageHeader(title: "Dashboard")
                        .padding(.horizontal, Spacing.md)

                    MonthlySurplusCard(
                        incomes: appState.incomes,
                        expenses: appState.expenses,
                        splitMethod: appState.household.surplusSplitMethod
                    )
                    .padding(.horizontal, Spacing.md)

                    HouseholdBudgetCard(
                        household: appState.household,
                        incomes: appState.incomes
                    )
                    .padding(.horizontal, Spacing.md)

                    MonthlyExpensesCard(
                        household: appState.household,
                        incomes: appState.incomes,
                        expenses: appState.expenses,
                        previousMonthTotal: appState.previousMonthExpenses,
                        onShowExpenses: { showExpenseList = true }
                    )
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.md)
            }
            .background(Color.storBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showExpenseList) {
            ExpenseListView()
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}

#Preview("Dark") {
    DashboardView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
