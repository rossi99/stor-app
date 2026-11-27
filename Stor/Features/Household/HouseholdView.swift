import SwiftUI

struct HouseholdView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss
    @State private var editor: Editor?
    @State private var showsSignOut = false

    private enum Editor: Identifiable, Hashable {
        case contributions, accounts, invite, budget, privacy, deleteAccount
        case member(Ledger)

        var id: String {
            switch self {
            case .contributions: "contributions"
            case .accounts: "accounts"
            case .invite: "invite"
            case .budget: "budget"
            case .privacy: "privacy"
            case .deleteAccount: "deleteAccount"
            case .member(let ledger): "member.\(ledger.rawValue)"
            }
        }
    }

    var body: some View {
        @Bindable var state = appState
        VStack(spacing: 0) {
            BackHeader(title: "Household") { dismiss() }
            Form {
                Section("Your household") {
                    Picker("People in household", selection: $state.householdSize) {
                        ForEach(1...4, id: \.self) { count in Text("\(count)").tag(count) }
                    }
                    ForEach(appState.members) { member in
                        Button { editor = .member(member.ledger) } label: {
                            settingLink(member.displayName,
                                        value: "\(money(member.netPay)) take-home · \(money(member.contribution)) to the pot")
                        }
                        .accessibilityHint("Edit name and take-home pay")
                    }
                    if appState.hasOpenSeat {
                        Button { editor = .invite } label: {
                            Label("Invite to household", systemImage: "person.badge.plus").frame(minHeight: 44)
                        }
                    }
                }
                Section("Shared spending") {
                    DisclosureGroup(appState.householdSummary) {
                        Text("Personal spending has its own budget. Shared costs come out of the joint pot, funded by your monthly contributions.")
                    }
                    Button { editor = .contributions } label: {
                        settingLink("Monthly contributions", value: money(appState.potContribution))
                    }
                    Button { editor = .accounts } label: {
                        settingLink("Linked accounts", value: appState.linkedAccounts.isEmpty ? "None yet" : "\(appState.linkedAccounts.count)")
                    }
                    Button { editor = .budget } label: {
                        let s = appState.plan.settings
                        settingLink("Budget settings", value: "\(s.essentialPct)/\(s.discretionaryPct)/\(s.savingPct)"
                                    + (s.cashCap.map { " · cash capped at \(money($0))" } ?? ""))
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
                Section {
                    Button("Privacy") { editor = .privacy }
                        .frame(minHeight: 44)
                    Button("Sign out", role: .destructive) { showsSignOut = true }
                        .frame(minHeight: 44)
                    Button("Delete account", role: .destructive) { editor = .deleteAccount }
                        .frame(minHeight: 44)
                } footer: {
                    if !appState.userEmail.isEmpty { Text("Signed in as \(appState.userEmail)") }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Sign out of Stór?", isPresented: $showsSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { appState.signOut() }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(item: $editor) { selected in
            switch selected {
            case .contributions:
                ContributionSettingsSheet(members: appState.members)
            case .invite:
                InviteSheet()
            case .budget:
                BudgetSettingsSheet(settings: appState.plan.settings)
            case .privacy:
                PrivacyView()
            case .deleteAccount:
                DeleteAccountSheet()
            case .member(let ledger):
                MemberSheet(member: appState.member(ledger))
            case .accounts:
                NavigationStack {
                    ScrollView {
                        LinkAccountsStep(showsHeading: false).padding(Spacing.screen)
                    }
                    .background(Color.storBackground)
                    .navigationTitle("Linked accounts")
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
