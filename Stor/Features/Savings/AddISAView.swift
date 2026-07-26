import SwiftUI

struct AddISAView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var memberID: UUID?
    @State private var type = "Stocks & Shares ISA"
    @State private var balance = ""
    @State private var contributionsThisYear = ""
    @State private var annualAllowance = "20000"

    private let types = ["Stocks & Shares ISA", "Cash ISA", "Lifetime ISA", "Innovative Finance ISA"]

    private var parsedBalance: Double { Double(balance) ?? 0 }
    private var parsedContributions: Double { Double(contributionsThisYear) ?? 0 }
    private var parsedAllowance: Double { Double(annualAllowance) ?? 0 }

    private var canAdd: Bool {
        memberID != nil && parsedAllowance > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("ISA details") {
                    Picker("Member", selection: $memberID) {
                        Text("Select member").tag(UUID?.none)
                        ForEach(appState.household.members) { member in
                            Text(member.name).tag(Optional(member.id))
                        }
                    }
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Balance", text: $balance)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Contributions this year", text: $contributionsThisYear)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Annual allowance", text: $annualAllowance)
                            .keyboardType(.decimalPad)
                    }
                }
                .listRowBackground(Color.storSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Add ISA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addISA() }
                        .disabled(!canAdd)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addISA() {
        guard let memberID, let member = appState.household.members.first(where: { $0.id == memberID }) else { return }

        let isa = ISA(
            id: UUID(),
            memberID: memberID,
            memberName: member.name,
            type: type,
            balance: parsedBalance,
            contributionsThisYear: parsedContributions,
            annualAllowance: parsedAllowance
        )
        appState.isas.append(isa)
        dismiss()
    }
}

#Preview {
    AddISAView()
        .environment(AppState())
}
