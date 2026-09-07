import SwiftUI

/// Every envelope for the selected ledger, with the month's totals on top.
struct BudgetView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                ScreenTitle("September envelopes")

                SegmentedPill(
                    options: Ledger.displayOrder,
                    selection: $state.ledger,
                    height: 32,
                    label: { appState.name(for: $0) }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .screenInset()
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.md)

            ScrollView {
                VStack(spacing: 0) {
                    totals
                        .padding(.bottom, 14)

                    RowCard {
                        ForEach(Array(appState.envelopes.enumerated()), id: \.element.id) { index, envelope in
                            EnvelopeDetailRow(
                                envelope: envelope,
                                accent: appState.ledger.accent,
                                soft: appState.ledger.soft,
                                isExpanded: appState.expandedCategory == envelope.name,
                                isFirst: index == 0
                            ) {
                                appState.toggleExpanded(envelope.name)
                            }
                        }
                    }

                    unbudgeted
                }
                .screenInset()
                .padding(.top, Spacing.xs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
    }

    private var totals: some View {
        HStack(spacing: Spacing.sm + 2) {
            CompactStat(label: "Budgeted", value: money(appState.budgetedTotal))
            CompactStat(label: "Spent", value: money(appState.spentTotal))
            CompactStat(
                label: "Left",
                value: money(appState.leftTotal),
                valueColor: appState.isBudgetTight ? .storNegative : .storInk,
                fill: appState.isBudgetTight ? .storNegativeSoft : .storSurface
            )
        }
    }

    private var unbudgeted: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(appState.ledger == .joint ? "Unbudgeted in the pot" : "Unspent, rolls over")
                .font(.text(13))
                .foregroundStyle(Color.storSecondaryLabel)
            Spacer(minLength: Spacing.sm)
            MonoText(money(appState.ledger == .joint ? MockData.unbudgetedInPot : 0), size: 13)
        }
        .padding(.horizontal, Spacing.xxs)
        .padding(.top, Spacing.lg)
    }
}

#Preview {
    BudgetView().environment(AppState())
}
