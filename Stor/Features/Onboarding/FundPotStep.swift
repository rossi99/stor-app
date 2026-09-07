import SwiftUI

/// Step 3 — the standing order into the joint pot, and whether it clears the
/// household's average shared outgoings.
struct FundPotStep: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeading(lead: "Fund the", trail: "joint pot", step: 3)

            Text("Monthly transfer from each personal account. Everything shared is paid from here.")
                .onboardingBody()
                .padding(.bottom, Spacing.xxl)

            ForEach(appState.members) { member in
                contributionCard(member)
                    .padding(.bottom, member.ledger == .ana ? 14 : Spacing.xl - 2)
            }

            total
        }
    }

    private func contributionCard(_ member: HouseholdMember) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(member.firstName)
                    .font(.text(14, weight: .semibold))
                    .foregroundStyle(Color.storInk)
                Spacer(minLength: Spacing.sm)
                MonoText("\(member.contributionPercent)% of net pay", size: 11,
                         color: .storTertiaryLabel)
            }
            .padding(.bottom, 14)

            HStack(spacing: 14) {
                stepButton("minus") {
                    appState.adjustContribution(member.ledger, by: -50)
                }

                Text(money(member.contribution))
                    .font(.display(32))
                    .tracking(-0.32)
                    .foregroundStyle(Color.storInk)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                stepButton("plus") {
                    appState.adjustContribution(member.ledger, by: 50)
                }
            }
        }
        .padding(Spacing.lg + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.storSurface)
        .clipShape(.rect(cornerRadius: Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(Color.storBorder, lineWidth: Stroke.hairline)
        }
    }

    private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.storInk)
                .frame(width: 38, height: 38)
                .overlay {
                    Circle().strokeBorder(Color.storBorder,
                                          lineWidth: Stroke.hairline)
                }
        }
        .buttonStyle(.plain)
    }

    private var total: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.storBorder)
                .frame(height: Stroke.hairline)
                .padding(.bottom, Spacing.lg)

            HStack(alignment: .firstTextBaseline) {
                MonoLabel("Joint pot / month", size: 10.5,
                          color: .storTertiaryLabel)
                Spacer(minLength: Spacing.sm)
                Text(money(appState.potContribution))
                    .font(.display(26))
                    .foregroundStyle(Color.storInk)
            }

            Text(potNote)
                .font(.text(12.5))
                .lineSpacing(2)
                .foregroundStyle(appState.potFallsShort
                                 ? Color.storNegative
                                 : Color.storSecondaryLabel)
                .padding(.top, Spacing.sm)
        }
    }

    private var potNote: String {
        let average = money(MockData.averageSharedOutgoings)
        if appState.potFallsShort {
            return "Below your average shared outgoings of \(average). The pot would run dry around the 24th."
        }
        let headroom = money(appState.potContribution - MockData.averageSharedOutgoings)
        return "Covers your average shared outgoings of \(average) with \(headroom) of headroom."
    }
}
