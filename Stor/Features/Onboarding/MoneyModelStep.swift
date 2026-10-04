import SwiftUI

/// Introduce the supported arrangement without offering incomplete flows.
struct MoneyModelStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            StepHeading(lead: "Your own money.", trail: "A shared plan.", step: 1)
            Text("Stór uses two personal accounts and one joint pot. Keep personal allowances separate, and plan your shared spending together.")
                .onboardingBody()
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Label("Two personal budgets", systemImage: "person.2")
                Label("One pot for shared bills", systemImage: "tray.full")
                Label("Monthly contributions you can edit", systemImage: "calendar")
            }
            .font(.body)
            .foregroundStyle(Color.storInk)
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .storCard()
            Text("Next, choose your accounts and monthly contributions. You can edit both in Household.")
                .onboardingBody()
        }
    }
}
