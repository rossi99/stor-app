import SwiftUI

/// The highest-priority envelopes for the selected ledger, with a link to the full set.
struct EnvelopeSummaryCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardHeader(
                label: appState.envelopes.contains(where: \.isOver) ? "Needs attention" : "Budget check",
                actionTitle: "Budget"
            ) {
                appState.selectedTab = .budget
            }
            .padding(.bottom, appState.homeEnvelopes.isEmpty ? Spacing.xxs : 14)

            if appState.homeEnvelopes.isEmpty {
                EmptyCardNote(text: "No envelopes yet. Spending you add will show here by category.")
            }
            ForEach(appState.homeEnvelopes) { envelope in
                EnvelopeSummaryRow(envelope: envelope, accent: appState.ledger.accent)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard()
    }
}

/// The three bills nearest to leaving the pot.
struct BillsPreviewCard: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    private var upcoming: [Bill] {
        Array(appState.upcomingBills.prefix(3))
    }

    private var trailing: String {
        let total = upcoming.reduce(0) { $0 + $1.thisMonth }
        return "\(money(total)) by \(MonthCalendar.format(upcoming.last?.dueDate(in: appState.month) ?? appState.month.date, "d MMM"))"
    }

    var body: some View {
        if upcoming.isEmpty {
            NavigationLink(value: Route.bills) {
                LabelledCard(label: "Upcoming shared bills") {
                    EmptyCardNote(text: "No bills due. Add your shared bills so they show here before they leave the pot.")
                }
            }
            .buttonStyle(.plain)
        } else {
            billsCard
        }
    }

    private var billsCard: some View {
        NavigationLink(value: Route.bills) {
            VStack(alignment: .leading, spacing: 0) {
                CardHeader(
                    label: "Upcoming shared bills",
                    trailingText: trailing
                )
                .padding(.bottom, 13)

                AdaptiveStack(spacing: Spacing.sm) {
                    ForEach(upcoming) { bill in
                        billTile(bill)
                    }
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .storCard()
        }
        .buttonStyle(.plain)
    }

    private func billTile(_ bill: Bill) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel(MonthCalendar.format(bill.dueDate(in: appState.month) ?? appState.month.date, "EEE d").uppercased(), size: 10, tracking: 0.06,
                      color: .storTertiaryLabel)

            Text(money(bill.thisMonth))
                .storText(13, weight: .medium)
                .tracking(-0.13)
                .foregroundStyle(Color.storInk)
                .padding(.top, 5)
                .padding(.bottom, 2)

            Text(bill.isEstimated ? "\(bill.name), est." : bill.name)
                .storText(11)
                .lineSpacing(1)
                .foregroundStyle(Color.storSecondaryLabel)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 11)
        .background(Color.storBackground)
        .clipShape(.rect(cornerRadius: Radius.sm, style: .continuous))
    }
}

/// The three most recent movements across every ledger.
struct LatestCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardHeader(label: "Recent activity", actionTitle: "Ledger") {
                appState.selectedTab = .ledger
            }
            .padding(.bottom, Spacing.xs)

            if appState.allTransactions.isEmpty {
                EmptyCardNote(text: "Nothing yet. Add your first spend and it will show here.")
            }
            ForEach(Array(appState.allTransactions.prefix(3).enumerated()), id: \.element.id) { index, tx in
                CompactTransactionRow(transaction: tx, isFirst: index == 0)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard()
    }
}
