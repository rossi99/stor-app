import SwiftUI

struct AddPensionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var memberID: UUID?
    @State private var currentValue = ""
    @State private var target = ""

    private var parsedCurrent: Double { Double(currentValue) ?? 0 }
    private var parsedTarget: Double { Double(target) ?? 0 }

    private var canAdd: Bool {
        memberID != nil && parsedTarget > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pension details") {
                    Picker("Member", selection: $memberID) {
                        Text("Select member").tag(UUID?.none)
                        ForEach(appState.household.members) { member in
                            Text(member.name).tag(Optional(member.id))
                        }
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Current value", text: $currentValue)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Target", text: $target)
                            .keyboardType(.decimalPad)
                    }
                }
                .listRowBackground(Color.storSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Add pension")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addPension() }
                        .disabled(!canAdd)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addPension() {
        guard let memberID, let member = appState.household.members.first(where: { $0.id == memberID }) else { return }

        let pension = Pension(
            id: UUID(),
            memberID: memberID,
            memberName: member.name,
            currentValue: parsedCurrent,
            target: parsedTarget,
            lastUpdated: Date()
        )
        appState.pensions.append(pension)
        dismiss()
    }
}

#Preview {
    AddPensionView()
        .environment(AppState())
}
