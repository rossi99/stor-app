import SwiftUI

/// The budget sheet's settings: 50/30/20 targets, the loan allocation and the cash cap.
struct BudgetSettingsSheet: View {
    @Environment(AppState.self) private var appState
    private let original: BudgetSettings
    @State private var essential: Int
    @State private var discretionary: Int
    @State private var saving: Int
    @State private var loan: String
    @State private var isCapped: Bool
    @State private var cap: String

    init(settings: BudgetSettings) {
        original = settings
        _essential = State(initialValue: settings.essentialPct)
        _discretionary = State(initialValue: settings.discretionaryPct)
        _saving = State(initialValue: settings.savingPct)
        _loan = State(initialValue: settings.loanAllocation > 0 ? MoneyInput.entry(for: settings.loanAllocation) : "")
        _isCapped = State(initialValue: settings.cashCap != nil)
        _cap = State(initialValue: settings.cashCap.map(MoneyInput.entry(for:)) ?? "")
    }

    private var settings: BudgetSettings? {
        guard essential + discretionary + saving == 100,
              let loanAmount = loan.isEmpty ? 0 : MoneyInput.amount(from: loan) else { return nil }
        let capAmount: Double?
        if isCapped {
            guard let amount = MoneyInput.amount(from: cap) else { return nil }
            capAmount = amount
        } else {
            capAmount = nil
        }
        return BudgetSettings(essentialPct: essential, discretionaryPct: discretionary, savingPct: saving,
                              loanAllocation: loanAmount, cashCap: capAmount)
    }

    var body: some View {
        CreateSheet(title: "Budget settings", saveTitle: "Save", canSave: settings != nil && settings != original,
                    hasContent: settings != original) {
            settings.map(appState.saveBudget) ?? false
        } form: {
            Section {
                Stepper("Essential \(essential)%", value: $essential, in: 0...100, step: 5)
                Stepper("Discretionary \(discretionary)%", value: $discretionary, in: 0...100, step: 5)
                Stepper("Saving \(saving)%", value: $saving, in: 0...100, step: 5)
            } header: {
                Text("50/30/20 targets")
            } footer: {
                let total = essential + discretionary + saving
                Text(total == 100 ? "Shares of take-home pay for needs, wants and saving." : "These add up to \(total)%. Make them 100%.")
                    .foregroundStyle(total == 100 ? Color.storSecondaryLabel : Color.storNegative)
            }
            Section {
                MoneyField("Loan allocation a month", text: $loan, id: "budget.loan")
            } footer: {
                Text("A set amount for loans and debts. Anything repayments don’t need overpays them.")
            }
            Section {
                Toggle("Cap cash accounts", isOn: $isCapped)
                if isCapped {
                    MoneyField("Most per person", text: $cap, id: "budget.cap")
                }
            } footer: {
                Text(isCapped ? "Anything above the cap goes to investing." : "Everything left after bills is split evenly as cash.")
            }
        }
    }
}
