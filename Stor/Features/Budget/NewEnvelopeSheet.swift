import SwiftUI

struct NewEnvelopeSheet: View {
    @Environment(AppState.self) private var appState
    @State private var draft: EnvelopeDraft
    /// Fixed when opened, so the saved category doesn't vanish from the picker mid-dismiss.
    private let categories: [String]

    init(categories: [String]) {
        self.categories = categories
        _draft = State(initialValue: EnvelopeDraft(category: categories.first ?? ""))
    }

    var body: some View {
        CreateSheet(title: "New envelope", saveTitle: "Add envelope", canSave: draft.amount != nil,
                    hasContent: !draft.budget.isEmpty) {
            appState.createEnvelope(draft)
        } form: {
            Section {
                Picker("Category", selection: $draft.category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                MoneyField("Monthly budget", text: $draft.budget, id: "envelope.budget")
            } footer: {
                Text("For \(appState.name(for: appState.ledger)). Spending in this category counts against it.")
            }
        }
    }
}
