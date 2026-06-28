import SwiftUI

struct AddExpenseView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var name      = ""
    @State private var amount    = ""
    @State private var frequency = ExpenseFrequency.monthly
    @State private var category  = ExpenseCategory.bills

    private var parsedAmount: Double { Double(amount) ?? 0 }

    private var monthlyPreview: Double {
        parsedAmount * frequency.monthlyMultiplier
    }

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense details") {
                    TextField("Name", text: $name)
                    HStack {
                        Text("£")
                            .foregroundStyle(.secondary)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ExpenseFrequency.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { c in
                            Label(c.rawValue, systemImage: c.systemImage).tag(c)
                        }
                    }
                }
                .listRowBackground(Color.storSurface)

                if parsedAmount > 0 {
                    Section("Preview") {
                        HStack {
                            Text("Monthly equivalent")
                            Spacer()
                            Text(monthlyPreview.gbp)
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Text("Framework bucket")
                            Spacer()
                            Text(category.frameworkBucket.rawValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.storSurface)
                }

                if appState.household.requiresApprovals && appState.household.members.count > 1 {
                    Section {
                        Label(
                            "This expense will need approval from all household members before it's counted.",
                            systemImage: "info.circle"
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.storSurface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Add expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addExpense() }
                        .disabled(!canAdd)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addExpense() {
        let needsApproval = appState.household.requiresApprovals && appState.household.members.count > 1
        let status: ApprovalStatus = needsApproval
            ? .pendingApproval(agreedBy: [appState.currentMemberID])
            : .approved

        let expense = Expense(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            total: parsedAmount,
            frequency: frequency,
            category: category,
            addedBy: appState.currentMemberID,
            approvalStatus: status
        )
        appState.expenses.append(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environment(AppState())
}
