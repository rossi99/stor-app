import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var showExpenseList = false
    @State private var showForecast    = false

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

                    if appState.pendingExpenseCount > 0 {
                        PendingApprovalBanner(count: appState.pendingExpenseCount) {
                            showExpenseList = true
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    HouseholdBudgetCard(
                        household: appState.household,
                        incomes: appState.incomes
                    )
                    .padding(.horizontal, Spacing.md)

                    MonthlyExpensesCard(
                        household: appState.household,
                        incomes: appState.incomes,
                        expenses: appState.expenses,
                        previousMonthTotal: appState.previousMonthExpenses
                    )
                    .padding(.horizontal, Spacing.md)

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        SectionHeader(title: "Expenses") {
                            showExpenseList = true
                        }
                        .padding(.horizontal, Spacing.md)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(appState.expenses.prefix(4)) { expense in
                                    MiniExpenseCard(expense: expense)
                                }
                                Button {
                                    showExpenseList = true
                                } label: {
                                    VStack(spacing: Spacing.xs) {
                                        Image(systemName: "ellipsis")
                                            .font(.title3)
                                        Text("All")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                    .frame(width: 100, height: 100)
                                    .background(Color.storSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                    }

                    Button {
                        showForecast = true
                    } label: {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(Color.storAccent)
                            Text("Open Forecast")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(Spacing.md)
                        .storCard()
                    }
                    .buttonStyle(.plain)
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
        .sheet(isPresented: $showForecast) {
            ForecastView(isPresentedAsSheet: true)
        }
    }
}

struct MiniExpenseCard: View {
    let expense: Expense

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: expense.category.systemImage)
                .font(.body)
                .foregroundStyle(Color.storAccent)
            Spacer()
            Text(expense.name)
                .font(.caption.weight(.medium))
                .lineLimit(2)
            Text(expense.monthlyAmount.gbpRounded)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.sm)
        .frame(width: 100, height: 100)
        .background(Color.storSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
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
