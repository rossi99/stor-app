import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var name            = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var showHouseholdSetup = false

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        passwordsMatch
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Create your account")
                            .font(.storLargeTitle)
                        Text("Tell us a little about you")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, Spacing.sm)

                    VStack(spacing: Spacing.sm) {
                        FloatingLabelField(label: "Full name", text: $name, keyboard: .default)
                        FloatingLabelField(label: "Email", text: $email, keyboard: .emailAddress)
                        FloatingLabelField(label: "Password", text: $password, isSecure: true)
                        FloatingLabelField(label: "Confirm password", text: $confirmPassword, isSecure: true)

                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords don't match")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
                    appState.userName  = name
                    appState.userEmail = email
                    showHouseholdSetup = true
                } label: {
                    Text("Continue")
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
            .navigationDestination(isPresented: $showHouseholdSetup) {
                HouseholdSetupView(mode: .create)
            }
        }
    }
}

struct FloatingLabelField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Group {
                if isSecure {
                    SecureField(label, text: $text)
                } else {
                    TextField(label, text: $text)
                }
            }
            .keyboardType(keyboard)
            .autocorrectionDisabled()
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
            .font(.body)
            .foregroundStyle(.storLabel)
            .tint(.storAccent)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .background(Color.storSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        }
    }
}

#Preview {
    SignUpView()
        .environment(AppState())
}

#Preview("Dark") {
    SignUpView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
