import SwiftUI

struct AddSavingsPotView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "🏺"
    @State private var current = ""
    @State private var target = ""
    @State private var monthlyContribution = ""

    private var parsedCurrent: Double { Double(current) ?? 0 }
    private var parsedTarget: Double { Double(target) ?? 0 }
    private var parsedMonthly: Double { Double(monthlyContribution) ?? 0 }

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && parsedTarget > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pot details") {
                    TextField("Emoji", text: $emoji)
                    TextField("Name", text: $name)
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Current balance", text: $current)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Target", text: $target)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Monthly contribution", text: $monthlyContribution)
                            .keyboardType(.decimalPad)
                    }
                }
                .listRowBackground(Color.storSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Add savings pot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addPot() }
                        .disabled(!canAdd)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addPot() {
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespaces)
        let pot = SavingsPot(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            current: parsedCurrent,
            target: parsedTarget,
            monthlyContribution: parsedMonthly,
            emoji: trimmedEmoji.isEmpty ? "🏺" : trimmedEmoji
        )
        appState.savingsPots.append(pot)
        dismiss()
    }
}

#Preview {
    AddSavingsPotView()
        .environment(AppState())
}
