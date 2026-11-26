import SwiftUI

/// Introduce the supported arrangement without offering incomplete flows.
struct MoneyModelStep: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        VStack(alignment: .leading, spacing: Spacing.xl) {
            StepHeading(lead: "Your own money.", trail: "A shared plan.", step: 1)
            Text("Stór gives everyone in your household a personal account, plus one joint pot. Keep personal allowances separate, and plan your shared spending together.")
                .onboardingBody()
            VStack(alignment: .leading, spacing: Spacing.sm) {
                MonoLabel("People in your household", size: 10.5, tracking: 0.14, color: .storTertiaryLabel)
                SegmentedPill(options: Array(1...4), selection: $state.householdSize,
                              height: 40, label: { "\($0)" })
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("People in your household")
                Text("You can change this later in Household.")
                    .storText(14).foregroundStyle(Color.storSecondaryLabel)
            }
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Label(appState.householdSummary, systemImage: appState.householdSize == 1 ? "person" : "person.2")
                Label("One pot for shared bills", systemImage: "tray.full")
                Label("Monthly contributions you can edit", systemImage: "calendar")
            }
            .font(.body)
            .foregroundStyle(Color.storInk)
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .storCard()
            Text(appState.snapshot.linkableAccounts.isEmpty
                 ? "Next, set your monthly contributions. You can edit them in Household."
                 : "Next, choose your accounts and monthly contributions. You can edit both in Household.")
                .onboardingBody()
        }
    }
}
