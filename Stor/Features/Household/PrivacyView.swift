import SwiftUI

/// What Stór stores and who sees it, reachable before and after signing in.
/// shortcut: in-app text only; App Store Connect also needs this hosted at a public URL with a contact address.
struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(String, String)] = [
        ("What Stór stores",
         "Your email address and a protected form of your password, or, if you sign in with Apple or Google, the account ID and email address they share with Stór. Names and take-home pay you enter for your household. Bills, budget settings, goals, contributions and spending you add. Nothing is read from your bank."),
        ("Why",
         "Only to run your household's budget: working out each month's bills, transfers, 50/30/20 check and forecast. Stór shows no adverts and sells nothing to anyone."),
        ("Who sees it",
         "People in your household see the joint bills, the plan, everyone's take-home pay and each person's cash-account total. Your own cash-account bills and personal spending are shown only to you."),
        ("On this phone",
         "Your sign-in is kept in this device's keychain. It is never backed up or synced, and signing out removes it."),
        ("Deleting your account",
         "Household → Delete account removes your account straight away. If you are the only person in the household, everything in it goes too. Otherwise your personal bills, spending, name and pay are removed and the household keeps its joint bills."),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    ForEach(sections, id: \.0) { title, body in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(title).storText(17, weight: .semibold).foregroundStyle(Color.storInk)
                            Text(body).onboardingBody()
                        }
                    }
                }
                .padding(Spacing.screen)
            }
            .background(Color.storBackground)
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
