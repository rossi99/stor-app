import SwiftUI

/// Household net worth: the headline, the trend, then every account grouped by
/// who it belongs to.
struct WealthView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MonoLabel("Household net worth", size: 10.5, tracking: 0.14)

                Text(money(MockData.netWorth))
                    .font(.display(52))
                    .tracking(-1.3)
                    .foregroundStyle(Color.storInk)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.xxs)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                    MonoText(money.signed(appState.netWorthRangeGain), size: 12.5,
                             color: .storPositive)
                    Text(appState.netWorthRange.caption)
                        .font(.text(12.5))
                        .foregroundStyle(Color.storTertiaryLabel)
                }
                .padding(.bottom, Spacing.lg)

                chartCard
                    .padding(.bottom, Spacing.md)

                ForEach(appState.accountGroups) { group in
                    AccountGroupCard(group: group)
                        .padding(.bottom, Spacing.sm + 2)
                }

                liabilityToggle
            }
            .screenInset()
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
        .scrollIndicators(.hidden)
        .background(Color.storBackground)
    }

    private var chartCard: some View {
        @Bindable var state = appState

        return VStack(spacing: 14) {
            Sparkline(values: MockData.netWorthSeries(appState.netWorthRange))
                .animation(.easeInOut(duration: 0.3), value: appState.netWorthRange)

            HStack(spacing: 5) {
                ForEach(NetWorthRange.allCases) { range in
                    let isOn = appState.netWorthRange == range

                    Button {
                        appState.netWorthRange = range
                    } label: {
                        Text(range.rawValue)
                            .font(.mono(11))
                            .tracking(0.66)
                            .foregroundStyle(isOn ? Color.storBackground : Color.storSecondaryLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(isOn ? Color.storAccent : Color.storBackground)
                            .clipShape(.rect(cornerRadius: Radius.xs, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
        .storCard(radius: Radius.xl)
    }

    private var liabilityToggle: some View {
        Button {
            appState.showLiabilities.toggle()
        } label: {
            Text(appState.showLiabilities ? "Hide what you owe" : "Show what you owe")
                .font(.text(12.5, weight: .medium))
                .foregroundStyle(Color.storAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

/// One group of accounts under a tinted header carrying its owner's colour.
struct AccountGroupCard: View {
    let group: AccountGroup
    @Environment(\.money) private var money

    var body: some View {
        VStack(spacing: 0) {
            header

            ForEach(group.accounts) { account in
                row(account)
            }
        }
        .frame(maxWidth: .infinity)
        .storCard()
    }

    private var header: some View {
        HStack(spacing: 9) {
            Circle().fill(group.dot).frame(width: 8, height: 8)

            Text(group.name)
                .font(.text(13, weight: .semibold))
                .tracking(-0.065)
                .foregroundStyle(Color.storInk)
                .frame(maxWidth: .infinity, alignment: .leading)

            MonoText(money(group.total), size: 12.5)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(group.headerFill)
    }

    private func row(_ account: Account) -> some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: true)

            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.text(14))
                        .tracking(-0.07)
                        .foregroundStyle(Color.storInk)
                    MonoText(account.kind, size: 11, color: .storTertiaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                MonoText(money(account.value), size: 13,
                         color: account.isLiability ? .storNegative : .storInk)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, Spacing.md)
        }
    }
}

#Preview {
    WealthView().environment(AppState())
}
