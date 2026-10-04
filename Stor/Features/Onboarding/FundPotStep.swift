import SwiftUI

/// A shared editor for onboarding and household settings. Changes stay in the draft.
struct FundPotStep: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Binding var draft: ContributionDraft
    var showsHeading = true
    @FocusState private var focusedLedger: Ledger?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            if showsHeading { StepHeading(lead: "Fund the", trail: "joint pot", step: 3) }
            Text("Monthly contribution from each personal account, in \(money.currency.rawValue). Tap an amount to edit it.")
                .onboardingBody()

            ForEach(appState.members) { member in
                contributionCard(member)
            }
            total
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedLedger = nil }
            }
        }
    }

    private func contributionCard(_ member: HouseholdMember) -> some View {
        let entry = draft.entries[member.ledger] ?? ""
        let amount = MoneyInput.amount(from: entry)
        return VStack(alignment: .leading, spacing: Spacing.md) {
            AdaptiveStack(spacing: Spacing.sm) {
                Text(member.firstName).storText(17, weight: .semibold)
                Spacer(minLength: Spacing.sm)
                if let amount, member.netPay > 0 {
                    MonoText("\(Int((amount / member.netPay * 100).rounded()))% of net pay", size: 13,
                             color: .storSecondaryLabel)
                }
            }
            TextField("0.00", text: Binding(
                get: { draft.entries[member.ledger] ?? "" },
                set: { draft.entries[member.ledger] = $0 }
            ))
            .keyboardType(.decimalPad)
            .focused($focusedLedger, equals: member.ledger)
            .storDisplay(30)
            .padding(Spacing.md)
            .frame(minHeight: 52)
            .background(Color.storBackground, in: RoundedRectangle(cornerRadius: Radius.sm))
            .accessibilityLabel("\(member.firstName)’s monthly contribution in \(money.currency.rawValue)")
            .accessibilityIdentifier("contribution.\(member.ledger.rawValue)")

            if amount == nil && focusedLedger != member.ledger {
                Text("Enter an amount from 0 to 999,999.99, with up to two decimal places.")
                    .storText(14).foregroundStyle(Color.storNegative)
            }

            HStack {
                Text("Adjust by \(money(50))").storText(14).foregroundStyle(Color.storSecondaryLabel)
                Spacer()
                stepButton("minus", member: member, enabled: (amount ?? 0) > 0) {
                    draft.adjust(member.ledger, by: -50)
                }
                stepButton("plus", member: member, enabled: amount != nil && amount! < MoneyInput.maximum) {
                    draft.adjust(member.ledger, by: 50)
                }
            }
        }
        .foregroundStyle(Color.storInk)
        .padding(Spacing.lg)
        .storCard()
    }

    private func stepButton(_ symbol: String, member: HouseholdMember, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17))
                .frame(width: 44, height: 44)
                .background(Color.storBackground, in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
        .accessibilityLabel("\(symbol == "minus" ? "Decrease" : "Increase") \(member.firstName)’s contribution by \(money(50))")
    }

    private var total: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Divider()
            if let amount = draft.total {
                AdaptiveStack(spacing: Spacing.sm) {
                    Text("Joint pot per month").storText(15, weight: .medium)
                    Spacer()
                    Text(money(amount)).storDisplay(26)
                }
                Text("Planned top-up: day \(appState.topUpDay) each month")
                    .storText(14).foregroundStyle(Color.storSecondaryLabel)
                Text(potNote(amount))
                    .storText(14)
                    .foregroundStyle(amount < MockData.averageSharedOutgoings ? Color.storNegative : Color.storSecondaryLabel)
            } else {
                Text("Check both amounts to see your monthly total.")
                    .storText(15).foregroundStyle(Color.storSecondaryLabel)
            }
        }
    }

    private func potNote(_ amount: Double) -> String {
        let average = money(MockData.averageSharedOutgoings)
        if amount < MockData.averageSharedOutgoings {
            return "Below your average shared outgoings of \(average). Add \(money(MockData.averageSharedOutgoings - amount)) per month to cover the gap."
        }
        return "Covers your average shared outgoings of \(average) with \(money(amount - MockData.averageSharedOutgoings)) of headroom."
    }
}
