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
            .padding(.bottom, 14)

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
    @Environment(\.money) private var money

    private var upcoming: [Bill] {
        Array(MockData.bills.prefix(3))
    }

    var body: some View {
        NavigationLink(value: Route.bills) {
            VStack(alignment: .leading, spacing: 0) {
                CardHeader(
                    label: "Upcoming shared bills",
                    trailingText: "\(money(MockData.committedRemaining)) by 22 Sep"
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
            MonoLabel(weekdayLabel(for: bill.day), size: 10, tracking: 0.06,
                      color: .storTertiaryLabel)

            Text(money(bill.amount))
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

    /// September 2026 starts on a Tuesday, so day-of-week follows from the date.
    private func weekdayLabel(for day: Int) -> String {
        let names = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        return "\(names[(MockData.monthStartOffset + day - 1) % 7]) \(day)"
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
