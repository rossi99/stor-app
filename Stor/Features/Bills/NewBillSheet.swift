import SwiftUI

/// Adds a bill, or edits one when given a draft made from it.
struct NewBillSheet: View {
    @Environment(AppState.self) private var appState
    private let original: BillDraft
    private let isNew: Bool
    @State private var draft: BillDraft

    init(draft: BillDraft = BillDraft()) {
        original = draft
        isNew = draft.name.isEmpty
        _draft = State(initialValue: draft)
    }

    var body: some View {
        CreateSheet(title: isNew ? "New bill" : "Edit bill", saveTitle: isNew ? "Add bill" : "Save",
                    canSave: draft.bill() != nil && draft != original, hasContent: draft != original) {
            appState.saveBill(draft)
        } form: {
            Section {
                TextField("Name, like Council tax", text: $draft.name)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("bill.name")
                MoneyField("Amount", text: $draft.amount, id: "bill.amount")
                Picker("How often", selection: $draft.schedule) {
                    ForEach(Bill.Frequency.allCases, id: \.self) { Text($0.title).tag(BillDraft.Schedule.every($0)) }
                    Text("Specific months").tag(BillDraft.Schedule.specificMonths)
                }
                if draft.schedule == .specificMonths {
                    MonthPicker(months: $draft.months)
                }
                Toggle("Amount is an estimate", isOn: $draft.isEstimated)
            } footer: {
                Text(draft.schedule == .specificMonths
                     ? "The full amount lands in each month you pick."
                     : "Weekly counts as four a month; quarterly and yearly spread evenly.")
            }

            Section {
                Picker("Paid from", selection: $draft.paidFrom) {
                    Text("Joint pots").tag(Ledger.joint)
                    Text("Your cash account").tag(Ledger.you)
                }
                if draft.paidFrom == .joint {
                    TextField("Pot, like Household & utilities", text: $draft.group)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("bill.group")
                    if !appState.billGroupNames.isEmpty {
                        Picker("Existing pots", selection: $draft.group) {
                            Text("New pot").tag(draft.group)
                            ForEach(appState.billGroupNames.filter { $0 != draft.group }, id: \.self) { Text($0).tag($0) }
                        }
                    }
                    Picker("Type", selection: $draft.kind) {
                        ForEach(Bill.Kind.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    Picker("50/30/20", selection: $draft.category) {
                        ForEach(Bill.Category.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                }
            } footer: {
                Text(draft.paidFrom == .joint
                     ? "Loans use your loan allocation, savings pots get their own transfer, and investments go to investing."
                     : "Only you see your cash-account bills. Everyone else sees just the total.")
            }

            Section {
                Picker("Due day", selection: $draft.dueDay) {
                    Text("None").tag(Int?.none)
                    ForEach(1...31, id: \.self) { Text("Day \($0)").tag(Int?.some($0)) }
                }
                TextField("Note, like direct debit", text: $draft.meta)
            } footer: {
                Text("A due day puts the bill on the calendar. Days past the month's end land on its last day.")
            }

            if !isNew {
                Section {
                    DeleteBillButton(draft: original)
                }
            }
        }
    }
}

/// Twelve month toggles in a grid.
private struct MonthPicker: View {
    @Binding var months: Set<Int>

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: Spacing.xs) {
            ForEach(1...12, id: \.self) { month in
                let isOn = months.contains(month)
                Button(MonthCalendar.monthAbbreviation(month)) {
                    if isOn { months.remove(month) } else { months.insert(month) }
                }
                .buttonStyle(.bordered)
                .tint(isOn ? Color.storAccent : Color.storSecondaryLabel)
                .frame(minHeight: 44)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }
}

private struct DeleteBillButton: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let draft: BillDraft
    @State private var confirms = false

    var body: some View {
        Button("Delete bill", role: .destructive) { confirms = true }
            .frame(minHeight: 44)
            .confirmationDialog("Delete \(draft.name)?", isPresented: $confirms, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let bill = draft.bill() { appState.deleteBill(bill) }
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            }
    }
}
