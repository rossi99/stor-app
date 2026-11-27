import SwiftUI

/// Deletes the signed-in account after the password is entered again, or a fresh Apple or Google sign-in.
struct DeleteAccountSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var proof = DeletionProof()
    @State private var confirms = false
    @State private var error: String?
    @State private var isDeleting = false

    private var sharesHousehold: Bool { appState.members.contains { $0.ledger != .you && $0.hasAccount } }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(sharesHousehold
                         ? "Your account, your cash-account bills, personal spending, name and pay are deleted. Your household keeps its joint bills and plan, and your seat opens for a new invite."
                         : "Your account and your whole household are deleted: every bill, goal, contribution and spend. This can’t be undone.")
                }
                Section {
                    if appState.signInMethod == .password {
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .accessibilityIdentifier("delete.password")
                    } else {
                        Text("Confirm it’s you to delete your account.")
                        ProviderButtons(methods: [appState.signInMethod]) { _, token, code in
                            proof = DeletionProof(idToken: token, authorizationCode: code)
                            confirms = true
                        } onFailure: { error = $0 }
                    }
                } footer: {
                    if let error { Text(error).foregroundStyle(Color.storNegative) }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Delete account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .safeAreaInset(edge: .bottom) {
                if appState.signInMethod == .password {
                    PrimaryButton(title: isDeleting ? "Deleting…" : "Delete account", isEnabled: !password.isEmpty && !isDeleting,
                                  fill: .storNegative) {
                        proof = DeletionProof(password: password)
                        confirms = true
                    }
                    .accessibilityIdentifier("delete.submit")
                    .padding(Spacing.screen)
                    .background(Color.storBackground)
                }
            }
            .confirmationDialog("Delete your account for good?", isPresented: $confirms, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {
                    Task {
                        isDeleting = true
                        error = await appState.deleteAccount(proof)
                        isDeleting = false
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .interactiveDismissDisabled(isDeleting)
    }
}
