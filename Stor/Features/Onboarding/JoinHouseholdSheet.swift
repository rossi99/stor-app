import SwiftUI

/// Takes an invite code and moves this account into that household.
struct JoinHouseholdSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var error: String?
    @State private var isJoining = false

    private var canJoin: Bool { code.filter { $0.isLetter || $0.isNumber }.count == 8 && !isJoining }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("ABCD-EFGH", text: $code)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(.title3, design: .monospaced))
                        .accessibilityLabel("Invite code")
                        .accessibilityIdentifier("join.code")
                } footer: {
                    if let error {
                        Text(error).foregroundStyle(Color.storNegative)
                    } else {
                        Text("Joining replaces the empty household made when you signed up.")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Join a household")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: isJoining ? "Joining…" : "Join", isEnabled: canJoin) {
                    Task {
                        isJoining = true
                        error = await appState.joinHousehold(code: code)
                        isJoining = false
                        if error == nil { dismiss() }
                    }
                }
                .accessibilityIdentifier("join.submit")
                .padding(Spacing.screen)
                .background(Color.storBackground)
            }
        }
        .interactiveDismissDisabled(isJoining)
    }
}
