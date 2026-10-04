import SwiftUI

struct ContributionSettingsSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ContributionDraft
    @State private var showsDiscardConfirmation = false

    init(members: [HouseholdMember]) {
        _draft = State(initialValue: ContributionDraft(members: members))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                FundPotStep(draft: $draft, showsHeading: false)
                    .padding(Spacing.screen)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.storBackground)
            .navigationTitle("Monthly contributions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if draft.hasChanges { showsDiscardConfirmation = true }
                        else { dismiss() }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Save changes", isEnabled: draft.isValid && draft.hasChanges) {
                    if appState.saveContributions(draft) { dismiss() }
                }
                .accessibilityIdentifier("contribution.save")
                .padding(Spacing.screen)
                .background(Color.storBackground)
            }
        }
        .interactiveDismissDisabled(draft.hasChanges)
        .confirmationDialog("Discard your changes?", isPresented: $showsDiscardConfirmation, titleVisibility: .visible) {
            Button("Discard changes", role: .destructive) { dismiss() }
            Button("Keep editing", role: .cancel) { }
        }
    }
}
