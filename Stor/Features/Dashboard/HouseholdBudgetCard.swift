import SwiftUI

/// Combines the household's net income, the per-member split, the chosen budget
/// framework, and a single bar that divides total income across that framework.
struct HouseholdBudgetCard: View {
    let household: Household
    let incomes: [Income]

    private var netIncome: Double { incomes.reduce(0) { $0 + $1.netMonthly } }
    private var framework: Framework { household.framework }

    private var segments: [FrameworkSegment] {
        [
            FrameworkSegment(label: "Needs",   percent: framework.needsPercent,   color: .progressNeeds),
            FrameworkSegment(label: "Wants",   percent: framework.wantsPercent,   color: .progressWants),
            FrameworkSegment(label: "Savings", percent: framework.savingsPercent, color: .progressSavings),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Household Budget")
                .font(.storTitle3)

            // Net income + per-member split
            VStack(alignment: .leading, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Household net income")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.4)
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text(netIncome.gbpRounded)
                            .font(.storHero(size: 34))
                        Text("per month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: Spacing.sm) {
                    ForEach(incomes) { income in
                        HStack {
                            HStack(spacing: Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(Color.storAccent.opacity(0.12))
                                        .frame(width: 28, height: 28)
                                    Text(income.memberName.prefix(1))
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.storAccent)
                                }
                                Text(income.memberName.components(separatedBy: " ").first ?? income.memberName)
                                    .font(.subheadline)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(income.netMonthly.gbpRounded)
                                    .font(.storTabular(.subheadline, weight: .semibold))
                                Text("gross \(income.grossMonthly.gbpRounded)")
                                    .font(.storTabular(.caption2))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Divider()

            // Framework + single split bar
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Budget framework")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .kerning(0.4)
                        Text(framework.label)
                            .font(.storDisplay(.title2))
                    }
                    Spacer()
                }

                FrameworkSplitBar(segments: segments, totalIncome: netIncome)
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

private struct FrameworkSegment: Identifiable {
    let id = UUID()
    let label: String
    let percent: Double
    let color: Color
}

/// A single horizontal bar divided into the framework's buckets, with a legend
/// showing each bucket's share of total income.
private struct FrameworkSplitBar: View {
    let segments: [FrameworkSegment]
    let totalIncome: Double

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            GeometryReader { geo in
                let available = geo.size.width - CGFloat(segments.count - 1) * 2
                HStack(spacing: 2) {
                    ForEach(segments) { segment in
                        segment.color
                            .frame(width: max(0, available * CGFloat(segment.percent)))
                    }
                }
            }
            .frame(height: 12)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(spacing: Spacing.xs) {
                ForEach(segments) { segment in
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(segment.color)
                            .frame(width: 8, height: 8)
                        Text(segment.label)
                            .font(.subheadline)
                        Text(segment.percent.percentInt)
                            .font(.storTabular(.caption))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text((totalIncome * segment.percent).gbpRounded)
                            .font(.storTabular(.subheadline, weight: .medium))
                    }
                }
            }
        }
    }
}

#Preview {
    HouseholdBudgetCard(
        household: MockData.household,
        incomes: MockData.incomes
    )
    .padding()
    .background(Color.storBackground)
}

#Preview("Dark") {
    HouseholdBudgetCard(
        household: MockData.household,
        incomes: MockData.incomes
    )
    .padding()
    .background(Color.storBackground)
    .preferredColorScheme(.dark)
}
