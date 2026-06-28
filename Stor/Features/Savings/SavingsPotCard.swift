import SwiftUI

struct SavingsPotCard: View {
    let pot: SavingsPot

    private var ttg: TimeToGoalResult? {
        timeToGoal(current: pot.current, target: pot.target, monthlyContribution: pot.monthlyContribution)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                HStack(spacing: Spacing.sm) {
                    Text(pot.emoji)
                        .font(.title3)
                    Text(pot.name)
                        .font(.subheadline.weight(.semibold))
                }
                Spacer()
                Text("+\(pot.monthlyContribution.gbpRounded)/mo")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(pot.current.gbpRounded)
                        .font(.storDisplay(.title2))
                    Text(" / \(pot.target.gbpRounded)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ProgressBar(value: pot.progress, color: pot.isComplete ? .storSuccess : .storAccent)
            }

            if let ttg {
                TimeToGoalBadge(result: ttg)
            } else if pot.isComplete {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.storSuccess)
                        .font(.caption2)
                    Text("Goal reached!")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.storSuccess)
                }
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(MockData.savingsPots) { pot in
                SavingsPotCard(pot: pot)
            }
        }
        .padding()
    }
    .background(Color.storBackground)
}

#Preview("Dark") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(MockData.savingsPots) { pot in
                SavingsPotCard(pot: pot)
            }
        }
        .padding()
    }
    .background(Color.storBackground)
    .preferredColorScheme(.dark)
}
