import SwiftUI

struct HouseholdView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss
    @State private var editor: Editor?

    private enum Editor: String, Identifiable {
        case contributions, accounts
        var id: String { rawValue }
        var title: String { self == .contributions ? "Monthly contributions" : "Linked accounts" }
    }

    var body: some View {
        @Bindable var state = appState
        VStack(spacing: 0) {
            BackHeader(title: "Household") { dismiss() }
            Form {
                Section("Your household") {
                    ForEach(appState.members) { member in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(member.name).font(.headline)
                            Text("\(money(member.contribution)) per month")
                                .foregroundStyle(Color.storSecondaryLabel)
                        }
                        .padding(.vertical, Spacing.xxs)
                    }
                }
                Section("Shared spending") {
                    DisclosureGroup("Two personal accounts + one joint pot") {
                        Text("Personal spending has its own budget. Shared costs come out of the joint pot, funded by your monthly contributions.")
                    }
                    Button { editor = .contributions } label: {
                        settingLink("Monthly contributions", value: money(appState.potContribution))
                    }
                    Button { editor = .accounts } label: {
                        settingLink("Linked accounts", value: "\(appState.linkedAccounts.count)")
                    }
                    Picker("Planned top-up day", selection: $state.topUpDay) {
                        ForEach(1...28, id: \.self) { day in Text("Day \(day)").tag(day) }
                    }
                }
                Section {
                    Picker("Display currency", selection: $state.currency) {
                        ForEach(Currency.allCases, id: \.self) { currency in Text(currency.rawValue).tag(currency) }
                    }
                } footer: {
                    Text("Changes the currency symbol used for these figures. Amounts are not converted between currencies.")
                }
                Section {
                    Toggle("Hide balances", isOn: $state.privacyMode)
                    Toggle("Payslip check in recap", isOn: $state.showPayslipCheck)
                } footer: {
                    Text("Hide balances and transaction amounts on screen. The payslip check appears in your monthly recap.")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $editor) { selected in
            if selected == .contributions {
                ContributionSettingsSheet(members: appState.members)
            } else {
                NavigationStack {
                    ScrollView {
                        LinkAccountsStep(showsHeading: false).padding(Spacing.screen)
                    }
                    .background(Color.storBackground)
                    .navigationTitle(selected.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) { Button("Done") { editor = nil } }
                    }
                }
            }
        }
    }

    private func settingLink(_ title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(value).font(.subheadline).foregroundStyle(Color.storSecondaryLabel)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.footnote)
        }
        .frame(minHeight: 44)
        .foregroundStyle(Color.storInk)
    }
}
