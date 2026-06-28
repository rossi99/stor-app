import SwiftUI

/// The dashboard's "Monthly Expenses" section: the total spend this month with a
/// month-on-month comparison, then the framework allocation showing whether each
/// bucket is within its allocated budget.
struct MonthlyExpensesCard: View {
    let household: Household
    let incomes: [Income]
    let expenses: [Expense]
    let previousMonthTotal: Double

    private var netIncome: Double { incomes.reduce(0) { $0 + $1.netMonthly } }
    private var framework: Framework { household.framework }

    private var approved: [Expense] {
        expenses.filter { $0.approvalStatus.isApproved }
    }

    private var totalMonthly: Double {
        approved.reduce(0) { $0 + $1.monthlyAmount }
    }

    private var delta: Double { totalMonthly - previousMonthTotal }
    private var deltaFraction: Double {
        previousMonthTotal > 0 ? delta / previousMonthTotal : 0
    }
    private var isUp: Bool { delta > 0 }

    private var thisMonthName: String {
        Date().formatted(.dateTime.month(.wide))
    }
    private var lastMonthName: String {
        let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return date.formatted(.dateTime.month(.wide))
    }

    private func actual(for bucket: FrameworkBucket) -> Double {
        approved
            .filter { $0.category.frameworkBucket == bucket }
            .reduce(0) { $0 + $1.monthlyAmount }
    }

    // Waterfall budgets: any surplus in a bucket rolls into the next
    // (needs → wants → savings); any overspend is taken from the next.
    private var needsBudget: Double { netIncome * framework.needsPercent }
    private var wantsBudget: Double {
        netIncome * framework.wantsPercent + (needsBudget - actual(for: .needs))
    }
    private var savingsBudget: Double {
        netIncome * framework.savingsPercent + (wantsBudget - actual(for: .wants))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Monthly Expenses")
                .font(.storTitle3)

            // Total spend + comparison with last month
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\(thisMonthName)'s Expenses")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.4)
                Text(totalMonthly.gbpRounded)
                    .font(.storHero(size: 34))

                HStack(spacing: Spacing.sm) {
                    if abs(delta) >= 1 {
                        HStack(spacing: 3) {
                            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption2.weight(.bold))
                            Text("\(abs(delta).gbpRounded) (\(abs(deltaFraction).percentInt))")
                                .font(.storTabular(.subheadline, weight: .medium))
                        }
                        .foregroundStyle(isUp ? Color.storNegative : Color.storPositive)
                        Text("vs \(lastMonthName)'s expenses")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("level with last month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            // Framework allocation — within budget vs over
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Framework allocation")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.4)
                    Spacer()
                    Text("Spent of budget")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                VStack(spacing: Spacing.lg) {
                    AllocationRow(
                        label: "Needs",
                        expectedAmount: needsBudget,
                        actualAmount: actual(for: .needs),
                        color: .progressNeeds
                    )
                    AllocationRow(
                        label: "Wants",
                        expectedAmount: wantsBudget,
                        actualAmount: actual(for: .wants),
                        color: .progressWants,
                        carryOver: needsBudget - actual(for: .needs)
                    )
                    AllocationRow(
                        label: "Savings",
                        expectedAmount: savingsBudget,
                        actualAmount: actual(for: .savings),
                        color: .progressSavings,
                        carryOver: wantsBudget - actual(for: .wants)
                    )
                }
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

#Preview {
    MonthlyExpensesCard(
        household: MockData.household,
        incomes: MockData.incomes,
        expenses: MockData.expenses,
        previousMonthTotal: MockData.previousMonthExpenses
    )
    .padding()
    .background(Color.storBackground)
}

#Preview("Dark") {
    MonthlyExpensesCard(
        household: MockData.household,
        incomes: MockData.incomes,
        expenses: MockData.expenses,
        previousMonthTotal: MockData.previousMonthExpenses
    )
    .padding()
    .background(Color.storBackground)
    .preferredColorScheme(.dark)
}
