import SwiftUI

/// Household monthly surplus (net income minus approved expenses), broken down
/// per member. Each member's share is split in proportion to their net income.
struct MonthlySurplusCard: View {
    let incomes: [Income]
    let expenses: [Expense]
    var splitMethod: SurplusSplitMethod = .proportional

    private var netIncome: Double {
        incomes.reduce(0) { $0 + $1.netMonthly }
    }

    private var totalExpenses: Double {
        expenses
            .filter { $0.approvalStatus.isApproved }
            .reduce(0) { $0 + $1.monthlyAmount }
    }

    private var surplus: Double { netIncome - totalExpenses }
    private var isDeficit: Bool { surplus < 0 }

    private var shares: [MemberSurplus] {
        let count = incomes.count
        return incomes.map { income in
            let amount: Double
            switch splitMethod {
            case .proportional:
                let incomeFraction = netIncome > 0 ? income.netMonthly / netIncome : 0
                amount = surplus * incomeFraction
            case .even:
                amount = count > 0 ? surplus / Double(count) : 0
            }
            return MemberSurplus(
                id: income.id,
                firstName: income.memberName.components(separatedBy: " ").first ?? income.memberName,
                initial: String(income.memberName.prefix(1)),
                amount: amount
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Monthly surplus")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.4)
                Text(surplus.gbpRounded)
                    .font(.storHero(size: 34))
                    .foregroundStyle(isDeficit ? AnyShapeStyle(Color.storNegative) : AnyShapeStyle(.primary))
                Text(isDeficit ? "over budget this month" : "left after expenses")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(spacing: Spacing.sm) {
                ForEach(shares) { share in
                    HStack {
                        HStack(spacing: Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(Color.storAccent.opacity(0.12))
                                    .frame(width: 28, height: 28)
                                Text(share.initial)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.storAccent)
                            }
                            Text(share.firstName)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text(share.amount.gbpRounded)
                            .font(.storTabular(.subheadline, weight: .semibold))
                            .foregroundStyle(isDeficit ? Color.storNegative : .primary)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

private struct MemberSurplus: Identifiable {
    let id: UUID
    let firstName: String
    let initial: String
    let amount: Double
}

#Preview {
    MonthlySurplusCard(incomes: MockData.incomes, expenses: MockData.expenses)
        .padding()
        .background(Color.storBackground)
}

#Preview("Dark") {
    MonthlySurplusCard(incomes: MockData.incomes, expenses: MockData.expenses)
        .padding()
        .background(Color.storBackground)
        .preferredColorScheme(.dark)
}
