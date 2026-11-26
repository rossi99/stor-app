import SwiftUI

struct NewBillSheet: View {
    @Environment(AppState.self) private var appState
    @State private var draft = BillDraft()

    var body: some View {
        CreateSheet(title: "New bill", saveTitle: "Add bill", canSave: draft.bill() != nil,
                    hasContent: draft.hasContent) {
            appState.createBill(draft)
        } form: {
            Section {
                TextField("Name, like Council tax", text: $draft.name)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("bill.name")
                MoneyField("Amount", text: $draft.amount, id: "bill.amount")
                DatePicker("Due", selection: $draft.dueDay,
                           in: appState.month.startOfToday()..., displayedComponents: .date)
                Toggle("Amount is an estimate", isOn: $draft.isEstimated)
            } footer: {
                Text("Bills come out of the joint pot.")
            }
        }
    }
}
