import SwiftUI

/// Three steps on the deep accent ground: how you keep your money, which
/// accounts matter, and how much goes into the pot.
struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    @State private var contributions = ContributionDraft(members: [])
    @State private var hasLoadedContributions = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                stepIndicator
                    .padding(.bottom, 38)

                ScrollView {
                    Group {
                        switch appState.onboardingStep {
                        case 0:  MoneyModelStep()
                        case 1:  LinkAccountsStep()
                        default: FundPotStep(draft: $contributions)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
                    .padding(.top, Spacing.xxl - 2)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.storBackground)
            .toolbar(.hidden, for: .navigationBar)
            .animation(.easeInOut(duration: 0.25), value: appState.onboardingStep)
            .onAppear {
                if !hasLoadedContributions {
                    contributions = ContributionDraft(members: appState.members)
                    hasLoadedContributions = true
                }
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index <= appState.onboardingStep
                          ? Color.storAccent
                          : Color.storTrack)
                    .frame(height: 3)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: Spacing.md) {
            Button(appState.onboardingStep > 0 ? "Back" : "Skip") {
                appState.retreatOnboarding()
            }
            .storMono(11.5)
            .tracking(1.15)
            .textCase(.uppercase)
            .foregroundStyle(Color.storSecondaryLabel)
            .padding(.vertical, 14)
            .buttonStyle(.plain)

            PrimaryButton(
                title: appState.onboardingStep < 2 ? "Continue" : "Open the app",
                isEnabled: appState.onboardingStep < 2 || contributions.isValid
            ) {
                if appState.onboardingStep == 2 && !appState.saveContributions(contributions) { return }
                appState.advanceOnboarding()
            }
        }
    }
}

// MARK: - Shared step furniture

/// The two-tone step heading: a solid first line, a lighter second.
struct StepHeading: View {
    let lead: String
    let trail: String
    let step: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel("Step \(step) of 3", size: 10.5, tracking: 0.14,
                      color: .storTertiaryLabel)
                .padding(.bottom, Spacing.lg)

            VStack(alignment: .leading, spacing: 0) {
                Text(lead)
                    .foregroundStyle(Color.storInk)
                Text(trail)
                    .foregroundStyle(Color.storSecondaryLabel)
                    .fontWeight(.regular)
            }
            .storDisplay(40)
            .tracking(-0.6)
            .lineSpacing(-2)
            .padding(.bottom, Spacing.md)
        }
    }
}

extension View {
    /// Body copy on the onboarding ground.
    func onboardingBody() -> some View {
        storText(16)
            .lineSpacing(4)
            .foregroundStyle(Color.storBodyInk)
    }
}

#Preview {
    OnboardingView().environment(AppState())
}
