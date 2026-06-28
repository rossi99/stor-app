import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String
    @State private var didSend = false

    init(email: String = "") {
        _email = State(initialValue: email)
    }

    private var canSend: Bool {
        email.contains("@")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Reset password")
                            .font(.storLargeTitle)
                        Text(didSend
                             ? "Check your inbox for a link to reset your password."
                             : "Enter your email and we'll send you a reset link.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, Spacing.sm)

                    if !didSend {
                        FloatingLabelField(label: "Email", text: $email, keyboard: .emailAddress)
                    }

                    Spacer()
                }
                .padding(.horizontal, Spacing.lg)
            }
            .background(Color.storBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(didSend ? "Done" : "Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !didSend {
                    Button {
                        didSend = true
                    } label: {
                        Text("Send reset link")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSend ? Color.storAccent : Color(.systemFill))
                            .foregroundStyle(canSend ? .white : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                    }
                    .disabled(!canSend)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.md)
                    .background(Color.storBackground)
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView(email: "sarah@example.com")
}

#Preview("Dark") {
    ForgotPasswordView()
        .preferredColorScheme(.dark)
}
