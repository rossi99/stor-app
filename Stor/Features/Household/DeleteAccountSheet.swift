import SwiftUI

/// Deletes the signed-in account after the password is entered again.
struct DeleteAccountSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
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
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .accessibilityIdentifier("delete.password")
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
                PrimaryButton(title: isDeleting ? "Deleting…" : "Delete account", isEnabled: !password.isEmpty && !isDeleting,
                              fill: .storNegative) { confirms = true }
                    .accessibilityIdentifier("delete.submit")
                    .padding(Spacing.screen)
                    .background(Color.storBackground)
            }
            .confirmationDialog("Delete your account for good?", isPresented: $confirms, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {
                    Task {
                        isDeleting = true
                        error = await appState.deleteAccount(password: password)
                        isDeleting = false
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .interactiveDismissDisabled(isDeleting)
    }
}
