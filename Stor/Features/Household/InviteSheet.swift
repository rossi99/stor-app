import SwiftUI

/// Shows a fresh one-use code for an empty seat, ready to share.
struct InviteSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var invite: Invite?
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("They sign up for Stór, choose “Have an invite code?” and enter this. It works once, for 48 hours.")
                    .onboardingBody()

                if let invite {
                    MonoText(invite.code, size: 34)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .storCard()
                        .textSelection(.enabled)
                        .accessibilityLabel("Invite code \(invite.code.map(String.init).joined(separator: " "))")
                    Text("Expires \(invite.expiresAt.formatted(date: .abbreviated, time: .shortened)).")
                        .storText(14).foregroundStyle(Color.storSecondaryLabel)
                    ShareLink(item: "Join our household on Stór with the code \(invite.code).") {
                        Label("Share the code", systemImage: "square.and.arrow.up")
                    }
                    .frame(minHeight: 44)
                } else if let error {
                    Text(error).storText(15).foregroundStyle(Color.storNegative)
                    Button("Try again") { Task { await load() } }.frame(minHeight: 44)
                } else {
                    ProgressView().frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(Spacing.screen)
            .background(Color.storBackground)
            .navigationTitle("Invite to household")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .task { await load() }
        }
    }

    private func load() async {
        error = nil
        switch await appState.createInvite() {
        case .success(let fresh): invite = fresh
        case .failure(let failure): error = failure.message
        }
    }
}
