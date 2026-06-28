import Foundation

struct FinancialPosition {
    var monthlyIncome: Double
    var monthlyExpenses: Double
    var monthlySavings: Double

    var netSurplus: Double {
        monthlyIncome - monthlyExpenses - monthlySavings
    }

    var isPositive: Bool { netSurplus >= 0 }

    var expensesFraction: Double { monthlyExpenses / monthlyIncome }
    var savingsFraction: Double  { monthlySavings / monthlyIncome }
    var surplusFraction: Double  { max(netSurplus, 0) / monthlyIncome }
}
