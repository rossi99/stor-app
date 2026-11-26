import SwiftUI

struct GoalsView: View {
    @Environment(AppState.self) private var appState
    @State private var showsNewGoal = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitle("Shared goals")
                .frame(maxWidth: .infinity, alignment: .leading)
                .screenInset()
                .padding(.top, Spacing.md)
                .padding(.bottom, 14)

            if appState.goals.isEmpty && appState.snapshot.emergencyFund == nil {
                ContentUnavailableView {
                    Label("No shared goals yet", systemImage: "target")
                } description: {
                    Text("Goals you’re saving for together will show here, with what’s saved and when you’ll get there.")
                } actions: {
                    CreateButton(title: "Add a goal") { showsNewGoal = true }
                }
            } else {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(appState.goals) { goal in
                        GoalCard(goal: goal)
                    }

                    if let fund = appState.snapshot.emergencyFund {
                        emergencyFund(fund)
                    }

                    CreateButton(title: "Add a goal") { showsNewGoal = true }
                }
                .screenInset()
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
            }
        }
        .background(Color.storBackground)
        .sheet(isPresented: $showsNewGoal) { NewGoalSheet() }
    }

    private func emergencyFund(_ fund: EmergencyFund) -> some View {
        AccentPanel {
            MonoLabel("Emergency fund", size: 9.5, tracking: 0.12,
                      color: .storAccent.opacity(0.7))

            AdaptiveStack(spacing: Spacing.sm) {
                Text(String(format: "%.1f", fund.months))
                    .storDisplay(34)
                    .foregroundStyle(Color.storAccent)
                Text("months of household outgoings")
                    .storText(13.5)
                    .foregroundStyle(Color.storAccent.opacity(0.75))
            }
            .padding(.top, Spacing.sm)

            Text(fund.note)
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

            if !goal.note.isEmpty {
                Text(goal.note)
                    .storText(12.5)
                    .lineSpacing(2)
                    .foregroundStyle(Color.storSecondaryLabel)
                    .padding(.top, Spacing.md)
            }
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

    /// "Ready Mar 2028 · 24 months", counted from today.
    private var eta: String {
        let months = goal.monthsToGo
        guard months < .max else { return "Paused" }

        let ready = MonthCalendar.format(appState.month.adding(months: months), "MMM yyyy")
        return "Ready \(ready) · \(months) months"
    }
}

#if DEBUG
#Preview {
    GoalsView().environment(AppState.preview)
}
#endif
