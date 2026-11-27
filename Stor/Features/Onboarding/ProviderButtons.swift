import AuthenticationServices
import SwiftUI

/// Sign in with Apple and Google, used both to sign in and to confirm it's you before deleting the account.
struct ProviderButtons: View {
    let methods: [SignInMethod]
    /// Gets the ID token, plus Apple's authorization code.
    let onToken: (SignInMethod, String, String?) async -> Void
    let onFailure: (String) -> Void
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    var body: some View {
        VStack(spacing: Spacing.md) {
            if methods.contains(.apple) {
                SignInWithAppleButton(.continue) { $0.requestedScopes = [.email] } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                              let token = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                            return onFailure("Couldn’t sign in with Apple. Try again.")
                        }
                        let code = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
                        Task { await onToken(.apple, token, code) }
                    case .failure(ASAuthorizationError.canceled):
                        break
                    case .failure:
                        onFailure("Couldn’t sign in with Apple. Try again.")
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(.capsule)
            }
            if methods.contains(.google), !BackendConfig.googleClientID.isEmpty {
                PrimaryButton(title: "Continue with Google", fill: .storSurface, titleColor: .storInk) {
                    Task { await signInWithGoogle() }
                }
            }
        }
    }

    private func signInWithGoogle() async {
        let google = GoogleSignIn(clientID: BackendConfig.googleClientID)
        do {
            let callback = try await webAuthenticationSession.authenticate(
                using: google.authorizeURL, callbackURLScheme: google.redirectScheme, preferredBrowserSession: .shared)
            await onToken(.google, try await google.idToken(from: callback), nil)
        } catch ASWebAuthenticationSessionError.canceledLogin {
        } catch {
            onFailure("Couldn’t sign in with Google. Try again.")
        }
    }
}
