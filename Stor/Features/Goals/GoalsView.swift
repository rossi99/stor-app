import SwiftUI

struct GoalsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitle("Shared goals")
                .frame(maxWidth: .infinity, alignment: .leading)
                .screenInset()
                .padding(.top, Spacing.md)
                .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(appState.goals) { goal in
                        GoalCard(goal: goal)
                    }

                    emergencyFund
                }
                .screenInset()
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
    }

    private var emergencyFund: some View {
        AccentPanel {
            MonoLabel("Emergency fund", size: 9.5, tracking: 0.12,
                      color: .storAccent.opacity(0.7))

            AdaptiveStack(spacing: Spacing.sm) {
                Text(String(format: "%.1f", MockData.emergencyFundMonths))
                    .storDisplay(34)
                    .foregroundStyle(Color.storAccent)
                Text("months of household outgoings")
                    .storText(13.5)
                    .foregroundStyle(Color.storAccent.opacity(0.75))
            }
            .padding(.top, Spacing.sm)

            Text(MockData.emergencyFundNote)
                .storText(12.5)
                .lineSpacing(2)
                .foregroundStyle(Color.storAccent.opacity(0.75))
                .padding(.top, Spacing.sm + 2)
        }
    }
}

/// One goal — progress, an adjustable monthly contribution, and the resulting
/// completion date. Nudging the contribution moves the date.
struct GoalCard: View {
    let goal: Goal
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, Spacing.lg)

            AdaptiveStack(spacing: 7) {
                Text(money(goal.saved))
                    .storDisplay(34)
                    .tracking(-0.51)
                    .foregroundStyle(Color.storInk)
                Text("of \(money(goal.target))")
                    .storText(13.5)
                    .foregroundStyle(Color.storTertiaryLabel)
            }
            .padding(.bottom, Spacing.md)

            ProgressTrack(fraction: goal.fraction, height: TrackHeight.goal)
                .padding(.bottom, Spacing.lg)

            contribution

            Text(goal.note)
                .storText(12.5)
                .lineSpacing(2)
                .foregroundStyle(Color.storSecondaryLabel)
                .padding(.top, Spacing.md)
        }
        .padding(Spacing.lg + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard(radius: Radius.xl)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(goal.name)
                    .storText(17, weight: .semibold)
                    .tracking(-0.255)
                    .foregroundStyle(Color.storInk)
                MonoText(eta, size: 12, color: .storTertiaryLabel)
            }

            Spacer(minLength: Spacing.sm)

            MonoText("\(goal.percent)%", size: 11, color: .storAccent)
                .tracking(0.44)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.storAccentSoft)
                .clipShape(.rect(cornerRadius: Radius.xs, style: .continuous))
        }
    }

    private var contribution: some View {
        AdaptiveStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 3) {
                MonoLabel("Monthly", size: 9.5, tracking: 0.12)
                MonoText("\(money(goal.monthly))/mo", size: 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            CircleStepper(
                context: "\(goal.name) monthly contribution by \(money(Goal.step))",
                canDecrement: goal.monthly > Goal.minimumMonthly,
                onDecrement: { appState.adjustGoal(goal.id, by: -Goal.step) },
                onIncrement: { appState.adjustGoal(goal.id, by: Goal.step) }
            )
        }
    }

    /// "Ready Mar 2028 · 24 months", counted from September 2026.
    private var eta: String {
        let months = goal.monthsToGo
        guard months < .max else { return "Paused" }

        let names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let offset = 8 + months
        let year = 2026 + offset / 12
        return "Ready \(names[offset % 12]) \(year) · \(months) months"
    }
}

#Preview {
    GoalsView().environment(AppState())
}
