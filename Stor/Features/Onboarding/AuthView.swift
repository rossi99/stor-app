import SwiftUI

enum AuthMode: String, CaseIterable, Identifiable {
    case signIn = "Sign in"
    case signUp = "Create account"

    var id: String { rawValue }
}

enum AuthProvider: String {
    case apple = "Apple"
    case google = "Google"

    /// Apple's Hide My Email returns a relay address, so neither is a real inbox.
    var email: String {
        switch self {
        case .apple:  "a1b2c3d4e5@privaterelay.appleid.com"
        case .google: "ana.whitfield@gmail.com"
        }
    }
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

                    fields
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                PrimaryButton(
                    title: mode.rawValue,
                    isEnabled: canContinue
                ) {
                    switch mode {
                    case .signIn: appState.signIn(email: trimmedEmail)
                    case .signUp: appState.signUp(email: trimmedEmail)
                    }
                }
                .padding(.top, Spacing.xxl - 2)

                divider
                    .padding(.vertical, Spacing.xl)

                VStack(spacing: Spacing.md) {
                    SocialButton(title: "Continue with Apple", symbol: "apple.logo") {
                        continueWith(.apple)
                    }

                    SocialButton(title: "Continue with Google") {
                        continueWith(.google)
                    }
                }
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
    }

    private func continueWith(_ provider: AuthProvider) {
        appState.continueWith(email: provider.email)
    }

    private var divider: some View {
        HStack(spacing: Spacing.md) {
            hairline
            MonoLabel("or", size: 10, tracking: 0.14,
                      color: .storQuaternaryLabel)
            hairline
        }
    }

    private var hairline: some View {
        Rectangle()
            .fill(Color.storBorder)
            .frame(height: Stroke.hairline)
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

/// Prototype styling. The real Apple button must be `SignInWithAppleButton`
/// from AuthenticationServices to meet Apple's guidelines.
struct SocialButton: View {
    let title: String
    var symbol: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .medium))
                }

                Text(title)
                    .storText(15, weight: .semibold)
                    .tracking(-0.15)
            }
            .foregroundStyle(Color.storInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .background(Color.storSurface)
            .clipShape(.capsule)
            .overlay {
                Capsule().strokeBorder(Color.storBorder,
                                       lineWidth: Stroke.hairline)
            }
        }
        .buttonStyle(.plain)
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
