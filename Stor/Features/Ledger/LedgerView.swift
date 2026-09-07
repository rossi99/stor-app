import SwiftUI

/// Every movement, grouped by day, filterable to one ledger.
struct LedgerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    /// `nil` is the "All" chip.
    private let filters: [Ledger?] = [nil, .joint, .ana, .sam]

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                ScreenTitle("Ledger")
                    .screenInset()

                ChipRow(options: filters, selection: $state.feedFilter) { filter in
                    filter.map { appState.name(for: $0) } ?? "All"
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.md)

            ScrollView {
                LazyVStack(spacing: Spacing.lg + 2) {
                    ForEach(appState.transactionGroups, id: \.label) { group in
                        section(label: group.label, rows: group.rows)
                    }
                }
                .screenInset()
                .padding(.top, Spacing.xxs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
        .animation(.easeInOut(duration: 0.2), value: appState.feedFilter)
    }

    private func section(label: String, rows: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                MonoLabel(label)
                Spacer(minLength: Spacing.sm)
                MonoText(money(outgoings(rows), decimals: 2), size: 10.5,
                         color: .storQuaternaryLabel)
            }
            .padding(.horizontal, 2)
            .padding(.bottom, Spacing.sm)

            RowCard {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, tx in
                    TransactionRow(transaction: tx, isFirst: index == 0)
                }
            }
        }
    }

    /// Money out only — income doesn't net off the day's spend.
    private func outgoings(_ rows: [Transaction]) -> Double {
        abs(rows.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
}

#Preview {
    LedgerView().environment(AppState())
}
