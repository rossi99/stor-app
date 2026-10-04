import SwiftUI

/// Step 2 — personal accounts stay private unless they are shared.
struct LinkAccountsStep: View {
    @Environment(AppState.self) private var appState

    var showsHeading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsHeading { StepHeading(lead: "Link the accounts", trail: "that matter", step: 2) }

            Text("\(appState.linkedAccounts.count) of \(MockData.linkableAccounts.count) accounts linked. Personal accounts stay private unless you share them.")
                .onboardingBody()
                .padding(.bottom, 22)

            VStack {
                VStack(spacing: Spacing.sm) {
                    ForEach(MockData.linkableAccounts) { account in
                        accountRow(account)
                    }
                }
            }

        }
    }

    private func accountRow(_ account: BankAccount) -> some View {
        let isLinked = appState.linkedAccounts.contains(account.id)

        return Button {
            appState.toggleLink(account.id)
        } label: {
            HStack(spacing: Spacing.md) {
                Text(account.initial)
                    .storMono(12, weight: .semibold)
                    .foregroundStyle(Color.storInk)
                    .frame(width: 30, height: 30)
                    .background(account.ledger.soft)
                    .clipShape(.rect(cornerRadius: Radius.sm - 3, style: .continuous))

                VStack(alignment: .leading, spacing: 0) {
                    Text(account.name)
                        .storText(14.5, weight: .medium)
                        .tracking(-0.145)
                        .foregroundStyle(Color.storInk)
                    MonoText(account.owner, size: 11.5,
                             color: .storTertiaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                MonoLabel(isLinked ? "Linked" : "Link", size: 11, tracking: 0.06,
                          color: isLinked ? .storAccent : .storQuaternaryLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(isLinked ? Color.storAccentSoft : Color.storSurface)
            .clipShape(.rect(cornerRadius: Radius.sm + 2, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.sm + 2, style: .continuous)
                    .strokeBorder(
                        isLinked ? Color.storAccent.opacity(0.45) : Color.storBorder,
                        lineWidth: Stroke.hairline
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
