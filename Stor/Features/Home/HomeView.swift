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
                        daysLeft: appState.month.daysLeft,
                        onSetUp: appState.ledger == .joint ? { appState.homePath.append(.household) } : nil
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
                MonoLabel(appState.month.todayLabel, size: 10.5, tracking: 0.14)
                Text(appState.snapshot.name.isEmpty ? "Your household" : appState.snapshot.name)
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
                            if !appState.snapshot.alerts.isEmpty {
                                Circle()
                                    .fill(Color.storNegative)
                                    .frame(width: 7, height: 7)
                                    .overlay { Circle().strokeBorder(Color.storSurface, lineWidth: 1.5) }
                                    .offset(x: -6, y: 6)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Alerts")

                NavigationLink(value: Route.household) {
                    Group {
                        if appState.members.allSatisfy(\.initials.isEmpty) {
                            Image(systemName: "person.2").font(.system(size: 13, weight: .medium))
                        } else {
                            Text(appState.members.map(\.initials).map { String($0.prefix(1)) }.joined())
                                .storMono(11.5, weight: .semibold)
                        }
                    }
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
            if let recap = appState.snapshot.recaps.last {
                StatTile(
                    label: "\(recap.month) recap",
                    value: money.signed(recap.total - recap.budget),
                    footnote: "vs budget"
                ) {
                    appState.selectedRecapID = recap.id
                    appState.selectedTab = .wealth
                    appState.wealthPath = [.recap]
                }
            }

            if let netWorth = appState.snapshot.netWorth {
                StatTile(
                    label: "Net worth",
                    value: money.thousands(netWorth.current),
                    footnote: "\(money.signed(netWorth.monthlyChange)) this month",
                    footnoteColor: netWorth.monthlyChange < 0 ? .storNegative : .storPositive
                ) {
                    appState.wealthPath = []
                    appState.selectedTab = .wealth
                }
            }
        }
    }
}
