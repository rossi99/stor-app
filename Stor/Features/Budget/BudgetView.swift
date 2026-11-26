import SwiftUI

/// Every envelope for the selected ledger, with the month's totals on top.
struct BudgetView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @State private var showsNewEnvelope = false

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                ScreenTitle("\(appState.month.monthName) envelopes")

                SegmentedPill(
                    options: appState.ledgers,
                    selection: $state.ledger,
                    height: 32,
                    label: { appState.name(for: $0) }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .screenInset()
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.md)

            if appState.envelopes.isEmpty {
                ContentUnavailableView {
                    Label("No envelopes yet", systemImage: "chart.pie")
                } description: {
                    Text("Spending you add to \(appState.name(for: appState.ledger)) will show here by category.")
                } actions: {
                    newEnvelopeButton
                    AddSpendButton(ledger: appState.ledger)
                }
            } else {
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

                    newEnvelopeButton
                        .padding(.top, Spacing.lg)
                }
                .screenInset()
                .padding(.top, Spacing.xs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
            }
        }
        .background(Color.storBackground)
        .sheet(isPresented: $showsNewEnvelope) {
            NewEnvelopeSheet(categories: appState.unbudgetedCategories)
        }
    }

    @ViewBuilder private var newEnvelopeButton: some View {
        if !appState.unbudgetedCategories.isEmpty {
            CreateButton(title: "Add envelope") { showsNewEnvelope = true }
        }
    }

    private var totals: some View {
        AdaptiveStack(spacing: Spacing.sm + 2) {
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
        AdaptiveStack(spacing: Spacing.sm) {
            Text(appState.ledger == .joint ? "Unbudgeted in the pot" : "Unspent, rolls over")
                .storText(13)
                .foregroundStyle(Color.storSecondaryLabel)
            Spacer(minLength: Spacing.sm)
            MonoText(money(appState.unbudgetedTotal), size: 13)
        }
        .padding(.horizontal, Spacing.xxs)
        .padding(.top, Spacing.lg)
    }
}

#if DEBUG
#Preview {
    BudgetView().environment(AppState.preview)
}
#endif
