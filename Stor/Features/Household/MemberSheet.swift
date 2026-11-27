import SwiftUI

/// Edit one member's name and take-home pay; the budget plan works from the pay.
struct MemberSheet: View {
    @Environment(AppState.self) private var appState
    private let original: MemberDraft
    @State private var draft: MemberDraft

    init(member: HouseholdMember) {
        original = MemberDraft(member)
        _draft = State(initialValue: original)
    }

    var body: some View {
        CreateSheet(title: draft.ledger == .you ? "You" : (original.trimmedName.isEmpty ? draft.ledger.defaultName : original.trimmedName),
                    saveTitle: "Save", canSave: draft.isValid && draft != original, hasContent: draft != original) {
            appState.saveMembers([draft])
        } form: {
            MemberFields(draft: $draft)
        }
    }
}

/// Name and take-home pay rows, shared with onboarding.
struct MemberFields: View {
    @Binding var draft: MemberDraft

    var body: some View {
        Section {
            TextField(draft.ledger == .you ? "Your name" : "Their name", text: $draft.name)
                .textContentType(draft.ledger == .you ? .name : nil)
                .textInputAutocapitalization(.words)
                .accessibilityIdentifier("member.\(draft.ledger.rawValue).name")
            MoneyField("Take-home pay a month", text: $draft.pay, id: "member.\(draft.ledger.rawValue).pay")
        } footer: {
            if draft.netPay == nil {
                Text("Enter an amount from 0 to 999,999.99, with up to two decimal places.")
                    .foregroundStyle(Color.storNegative)
            } else if draft.trimmedName.count > 60 {
                Text("Keep the name to 60 characters.").foregroundStyle(Color.storNegative)
            }
        }
    }
}
