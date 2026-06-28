import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showSignUp = false
    @State private var showSignIn = false

    var body: some View {
        ZStack {
            Image("WelcomeBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Stór")
                        .font(.storHero(size: 40))
                        .italic()
                    Text("Financial clarity, together.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: Spacing.md) {
                    Button {
                        showSignUp = true
                    } label: {
                        Text("Create an account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.storAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                    }

                    Button {
                        showSignIn = true
                    } label: {
                        Text("Sign in")
                            .font(.headline)
                            .foregroundStyle(.storAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.storSurface)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                    }
                }
                .padding(.top, Spacing.xl)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppState())
}

#Preview("Dark") {
    WelcomeView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
