import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            header
            HStack {
                Text("Your spending today").storText(14).foregroundStyle(Color.storSecondaryLabel)
                Spacer()
                AddSpendButton()
            }
            .screenInset()
            .padding(.bottom, Spacing.sm)
            ledgerToggle

            ScrollView {
                VStack(spacing: Spacing.md) {
                    HeroCard(
                        model: appState.safeToSpend,
                        accent: appState.ledger.accent,
                        daysLeft: MockData.daysLeftInMonth
                    )

                    EnvelopeSummaryCard()
                    BillsPreviewCard()
                    LatestCard()
                    statTiles
                }
                .screenInset()
                .padding(.top, Spacing.xxs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                MonoLabel(MockData.today, size: 10.5, tracking: 0.14)
                Text(MockData.householdName)
                    .storDisplay(27)
                    .tracking(-0.27)
                    .foregroundStyle(Color.storInk)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            Spacer(minLength: Spacing.sm)

            HStack(spacing: Spacing.sm) {
                NavigationLink(value: Route.alerts) {
                    Image(systemName: "bell")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.storInk)
                        .frame(width: 44, height: 44)
                        .background(Color.storSurface)
                        .clipShape(.circle)
                        .overlay {
                            Circle().strokeBorder(Color.storBorder, lineWidth: Stroke.hairline)
                        }
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(Color.storNegative)
                                .frame(width: 7, height: 7)
                                .overlay { Circle().strokeBorder(Color.storSurface, lineWidth: 1.5) }
                                .offset(x: -6, y: 6)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Alerts")

                NavigationLink(value: Route.household) {
                    Text(appState.members.map(\.initials).map { String($0.prefix(1)) }.joined())
                        .storMono(11.5, weight: .semibold)
                        .foregroundStyle(Color.storBackground)
                        .frame(width: 44, height: 44)
                        .background(Color.storAccent)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Household settings")
            }
        }
        .screenInset()
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm + 2)
    }

    private var ledgerToggle: some View {
        @Bindable var state = appState

        return SegmentedPill(
            options: Ledger.displayOrder,
            selection: $state.ledger,
            label: { appState.name(for: $0) },
            dot: { $0.accent }
        )
        .screenInset()
        .padding(.bottom, Spacing.md)
    }

    private var statTiles: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.sm + 2) { summaryTiles }
            VStack(spacing: Spacing.sm) { summaryTiles }
        }
    }

    @ViewBuilder private var summaryTiles: some View {
        Group {
            StatTile(
                label: "August recap",
                value: money.signed(MockData.augustRecapDelta),
                footnote: "vs budget"
            ) {
                appState.selectedTab = .wealth
                appState.wealthPath = [.recap]
            }

            StatTile(
                label: "Net worth",
                value: money.thousands(MockData.netWorth),
                footnote: "\(money.signed(MockData.netWorthMonthlyChange)) this month",
                footnoteColor: .storPositive
            ) {
                appState.wealthPath = []
                appState.selectedTab = .wealth
            }
        }
    }
}
