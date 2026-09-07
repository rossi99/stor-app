import SwiftUI

/// Three steps on the deep accent ground: how you keep your money, which
/// accounts matter, and how much goes into the pot.
struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        VStack(alignment: .leading, spacing: 0) {
            stepIndicator
                .padding(.bottom, 38)

            Group {
                switch appState.onboardingStep {
                case 0:  MoneyModelStep()
                case 1:  LinkAccountsStep()
                default: FundPotStep()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            footer
                .padding(.top, Spacing.xxl - 2)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.storBackground)
        .animation(.easeInOut(duration: 0.25), value: appState.onboardingStep)
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
            .font(.mono(11.5))
            .tracking(1.15)
            .textCase(.uppercase)
            .foregroundStyle(Color.storSecondaryLabel)
            .padding(.vertical, 14)
            .buttonStyle(.plain)

            PrimaryButton(
                title: appState.onboardingStep < 2 ? "Continue" : "Open the app"
            ) {
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
            .font(.display(40))
            .tracking(-0.6)
            .lineSpacing(-2)
            .padding(.bottom, Spacing.md)
        }
    }
}

extension View {
    /// Body copy on the onboarding ground.
    func onboardingBody() -> some View {
        font(.text(14.5))
            .lineSpacing(4)
            .foregroundStyle(Color.storBodyInk)
    }
}

#Preview {
    OnboardingView().environment(AppState())
}
