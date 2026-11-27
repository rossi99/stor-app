import SwiftUI

enum AuthMode: String, CaseIterable, Identifiable {
    case signIn = "Sign in"
    case signUp = "Create account"

    var id: String { rawValue }
}

/// The gate in front of onboarding. An existing account signs in and lands in
/// the app; a new one carries on into the three setup steps.
struct AuthView: View {
    @Environment(AppState.self) private var appState

    @State private var mode: AuthMode = .signIn
    @State private var email = ""
    @State private var password = ""

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespaces)
    }

    /// Loose on purpose — the server validates. Sign-in doesn't second-guess an
    /// existing password's length; only sign-up gets to impose the rule.
    private var canContinue: Bool {
        guard trimmedEmail.contains("@") else { return false }
        return mode == .signIn ? !password.isEmpty : password.count >= 8
    }

    @State private var showsPrivacy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    wordmark
                        .padding(.bottom, 30)

                    SegmentedPill(options: AuthMode.allCases, selection: $mode,
                                  height: 40, label: { $0.rawValue })
                        .padding(.bottom, Spacing.xl)

                    Text(caption)
                        .onboardingBody()
                        .frame(maxWidth: 300, alignment: .leading)
                        .padding(.bottom, Spacing.xxl)

                    ProviderButtons(methods: [.apple, .google]) { method, token, _ in
                        await appState.signIn(provider: method, idToken: token)
                    } onFailure: { appState.authError = $0 }

                    MonoLabel("or with email", size: 10.5, tracking: 0.14, color: .storTertiaryLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xl)

                    fields
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                if let error = appState.authError {
                    Text(error)
                        .storText(14)
                        .foregroundStyle(Color.storNegative)
                        .padding(.top, Spacing.lg)
                }

                PrimaryButton(
                    title: appState.isAuthenticating ? "One moment…" : mode.rawValue,
                    isEnabled: canContinue && !appState.isAuthenticating
                ) {
                    Task {
                        switch mode {
                        case .signIn: await appState.signIn(email: trimmedEmail, password: password)
                        case .signUp: await appState.signUp(email: trimmedEmail, password: password)
                        }
                    }
                }
                .padding(.top, Spacing.xxl - 2)

                Button("How Stór uses your data") { showsPrivacy = true }
                    .storText(14)
                    .foregroundStyle(Color.storSecondaryLabel)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.top, Spacing.md)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.storBackground)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.storBackground)
        .animation(.easeInOut(duration: 0.25), value: mode)
        .sheet(isPresented: $showsPrivacy) { PrivacyView() }
    }

    private var caption: String {
        switch mode {
        case .signIn: "Welcome back. Your household is where you left it."
        case .signUp: "We'll set up your household in three short steps."
        }
    }

    private var wordmark: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Stór")
                .storDisplay(34)
                .tracking(-0.4)
                .foregroundStyle(Color.storInk)

            MonoLabel("Financial clarity, together", size: 10.5, tracking: 0.14,
                      color: .storTertiaryLabel)
        }
    }

    private var fields: some View {
        VStack(spacing: Spacing.lg) {
            AuthField(label: "Email", text: $email,
                      keyboard: .emailAddress, content: .username)

            AuthField(label: "Password", text: $password, isSecure: true,
                      content: mode == .signIn ? .password : .newPassword)
            if mode == .signUp {
                Text("Use at least 8 characters.")
                    .storText(14).foregroundStyle(Color.storSecondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

}

/// A labelled field for the accent ground, where `storBackground` reads as ink.
struct AuthField: View {
    let label: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var content: UITextContentType?
    @State private var showsPassword = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            MonoLabel(label, size: 10.5, tracking: 0.14,
                      color: .storTertiaryLabel)

            HStack(spacing: Spacing.sm) {
                Group {
                    if isSecure && !showsPassword {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .focused($isFocused)
                .accessibilityLabel(label)
                .submitLabel(.done)
                .onSubmit { isFocused = false }

                if isSecure {
                    Button {
                        let wasFocused = isFocused
                        showsPassword.toggle()
                        if wasFocused {
                            Task { @MainActor in
                                await Task.yield()
                                isFocused = true
                            }
                        }
                    } label: {
                        Image(systemName: showsPassword ? "eye.slash" : "eye")
                            .font(.body)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(showsPassword ? "Hide password" : "Show password")
                }
            }
            .storText(15)
            .foregroundStyle(Color.storInk)
            .tint(Color.storAccent)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(keyboard)
            .textContentType(content)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .background(Color.storSurface)
            .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(Color.storBorder, lineWidth: Stroke.hairline)
            }
        }
    }
}

#Preview {
    AuthView().environment(AppState())
}
