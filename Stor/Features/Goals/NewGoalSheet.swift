import SwiftUI

struct NewGoalSheet: View {
    @Environment(AppState.self) private var appState
    @State private var draft = GoalDraft()

    var body: some View {
        CreateSheet(title: "New goal", saveTitle: "Add goal", canSave: draft.goal() != nil,
                    hasContent: draft.hasContent) {
            appState.createGoal(draft)
        } form: {
            Section {
                TextField("Name, like House deposit", text: $draft.name)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("goal.name")
                MoneyField("Target", text: $draft.target, id: "goal.target")
                MoneyField("Saved so far", text: $draft.saved, id: "goal.saved")
                MoneyField("Monthly contribution", text: $draft.monthly, id: "goal.monthly")
            } footer: {
                Text("Leave saved so far empty if you’re starting from nothing.")
            }
        }
    }
}
