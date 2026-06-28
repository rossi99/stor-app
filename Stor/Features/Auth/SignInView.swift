import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var email    = ""
    @State private var password = ""
    @State private var showForgotPassword = false

    private var canContinue: Bool {
        email.contains("@") && !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Welcome back")
                            .font(.storLargeTitle)
                        Text("Sign in to your account")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, Spacing.sm)

                    VStack(spacing: Spacing.sm) {
                        FloatingLabelField(label: "Email", text: $email, keyboard: .emailAddress)
                        FloatingLabelField(label: "Password", text: $password, isSecure: true)

                        Button("Forgot password?") {
                            showForgotPassword = true
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.storAccent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    Spacer()
                }
                .padding(.horizontal, Spacing.lg)
            }
            .background(Color.storBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    signIn()
                } label: {
                    Text("Sign in")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canContinue ? Color.storAccent : Color(.systemFill))
                        .foregroundStyle(canContinue ? .white : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                }
                .disabled(!canContinue)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
                .background(Color.storBackground)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: email)
            }
        }
    }

    private func signIn() {
        appState.userEmail       = email
        appState.isAuthenticated = true
        appState.hasHousehold    = true
        dismiss()
    }
}

#Preview {
    SignInView()
        .environment(AppState())
}

#Preview("Dark") {
    SignInView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
