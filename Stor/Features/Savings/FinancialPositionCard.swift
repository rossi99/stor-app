import SwiftUI

struct FinancialPositionCard: View {
    let position: FinancialPosition

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("This month")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.4)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(position.netSurplus.gbpRounded)
                    .font(.storHero(size: 34))
                    .foregroundStyle(position.isPositive ? Color.primary : .storNegative)
                Text("surplus")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                PositionBar(label: "In", amount: position.monthlyIncome, fraction: 1.0, color: .storSuccess)
                PositionBar(label: "Out", amount: position.monthlyExpenses, fraction: position.expensesFraction, color: .storWarning)
                PositionBar(label: "Saved", amount: position.monthlySavings, fraction: position.savingsFraction, color: .storAccent)
            }
            .frame(height: 6)
            .clipShape(Capsule())

            HStack(spacing: Spacing.xl) {
                PositionLegend(label: "Money in",  value: position.monthlyIncome,   color: .storSuccess)
                PositionLegend(label: "Expenses",  value: position.monthlyExpenses, color: .storWarning)
                PositionLegend(label: "Savings",   value: position.monthlySavings,  color: .storAccent)
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

private struct PositionBar: View {
    let label: String
    let amount: Double
    let fraction: Double
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity)
            .scaleEffect(x: CGFloat(fraction), anchor: .leading)
    }
}

private struct PositionLegend: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Spacing.xs) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(value.gbpRounded)
                .font(.storTabular(.subheadline, weight: .semibold))
        }
    }
}

#Preview {
    FinancialPositionCard(position: MockData.financialPosition)
        .padding()
        .background(Color.storBackground)
}

#Preview("Dark") {
    FinancialPositionCard(position: MockData.financialPosition)
        .padding()
        .background(Color.storBackground)
        .preferredColorScheme(.dark)
}
