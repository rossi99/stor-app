import SwiftUI

/// The shared shell for creating a goal, envelope or bill: a form, Cancel, and one save button.
struct CreateSheet<Fields: View>: View {
    let title: String
    let saveTitle: String
    let canSave: Bool
    let hasContent: Bool
    let save: () -> Bool
    @ViewBuilder let form: () -> Fields
    @Environment(\.dismiss) private var dismiss
    @State private var showsDiscardConfirmation = false

    var body: some View {
        NavigationStack {
            Form(content: form)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .background(Color.storBackground)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            if hasContent { showsDiscardConfirmation = true } else { dismiss() }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    PrimaryButton(title: saveTitle, isEnabled: canSave) {
                        if save() { dismiss() }
                    }
                    .accessibilityIdentifier("create.save")
                    .padding(Spacing.screen)
                    .background(Color.storBackground)
                }
        }
        .interactiveDismissDisabled(hasContent)
        .confirmationDialog("Discard this?", isPresented: $showsDiscardConfirmation, titleVisibility: .visible) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep editing", role: .cancel) { }
        }
    }
}

/// A labelled decimal amount in the display currency.
struct MoneyField: View {
    let label: String
    @Binding var text: String
    let id: String
    @Environment(\.money) private var money

    init(_ label: String, text: Binding<String>, id: String) {
        self.label = label
        _text = text
        self.id = id
    }

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 2) {
                Text(money.currency.symbol).foregroundStyle(Color.storSecondaryLabel)
                TextField("0", text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 140)
                    .accessibilityLabel(label)
                    .accessibilityIdentifier(id)
            }
        }
    }
}

/// The pill used to start a create flow, matching `AddSpendButton`.
struct CreateButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus")
                .storText(14, weight: .semibold)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .background(Color.storAccent, in: Capsule())
                .foregroundStyle(Color.storBackground)
        }
        .buttonStyle(.plain)
    }
}
