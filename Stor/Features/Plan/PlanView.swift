import SwiftUI

/// The month as the budget sheet sets it out: what comes in, where it goes, the payday checklist,
/// the 50/30/20 check, cash accounts and the year ahead.
struct PlanView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss
    /// Months from now; 0 shows this month's plan from app state.
    @State private var offset = 0
    @State private var browsed: BudgetPlan?
    @State private var showsSettings = false

    private var plan: BudgetPlan { offset == 0 ? appState.plan : browsed ?? .empty(month: monthKey) }
    private var monthDate: Date { appState.month.adding(months: offset) }
    private var monthKey: String { BudgetPlan.key(for: monthDate) }

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "Payday plan") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    monthSwitcher
                    if plan.income == 0 && plan.bills.isEmpty {
                        EmptyCardNote(text: "Add everyone’s take-home pay in Household and your bills, and the plan fills in.")
                            .padding(Spacing.lg)
                            .storCard()
                    }
                    overview
                    transfers
                    whereItGoes
                    split
                    biggest
                    cashAccounts
                    forecast
                    Button("Budget settings") { showsSettings = true }
                        .frame(minHeight: 44)
                    NavigationLink("All bills", value: Route.bills).frame(minHeight: 44)
                }
                .screenInset()
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsSettings) { BudgetSettingsSheet(settings: appState.plan.settings) }
        .task(id: offset) {
            guard offset != 0 else { return }
            browsed = nil
            browsed = await appState.loadPlan(month: monthKey)
        }
    }

    private var monthSwitcher: some View {
        HStack {
            Button { offset -= 1 } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                .accessibilityLabel("Previous month")
            Spacer()
            VStack(spacing: 2) {
                Text(MonthCalendar.format(monthDate, "MMMM yyyy")).storText(17, weight: .semibold)
                if offset != 0 {
                    Button("Back to this month") { offset = 0 }.storText(13)
                }
            }
            Spacer()
            Button { offset += 1 } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                .accessibilityLabel("Next month")
        }
        .foregroundStyle(Color.storInk)
    }

    private func share(_ amount: Double) -> String {
        plan.income > 0 ? "\(Int((amount / plan.income * 100).rounded()))% of income" : " "
    }

    private var overview: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            figure("Coming in", money(plan.income),
                   appState.members.map { "\($0.firstName) \(money($0.netPay))" }.joined(separator: " · "))
            figure("Bills & pots", money(plan.billsAndPots), share(plan.billsAndPots))
            figure("Invested", money(plan.invested), share(plan.invested))
            figure("Cash each", money(plan.cashEach),
                   plan.settings.cashCap.map { "Capped at \(money($0)), extra is invested" } ?? "Everything left, split evenly",
                   color: plan.cashEach < 0 ? .storNegative : .storSecondaryLabel)
        }
    }

    private func figure(_ label: String, _ value: String, _ note: String, color: Color = .storSecondaryLabel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MonoLabel(label)
            Text(value).storDisplay(22).foregroundStyle(Color.storInk)
            Text(note).storText(12).foregroundStyle(color).lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .padding(Spacing.md)
        .storCard()
        .accessibilityElement(children: .combine)
    }

    private func transferTitle(_ transfer: BudgetPlan.Transfer) -> String {
        let hub = appState.member(plan.hub).possessive
        switch transfer.kind {
        case .payIn: return "\(appState.member(transfer.ledger ?? .partner).possessive) pay → \(hub) account"
        case .pot, .investing: return "\(hub) account → \(transfer.group ?? "")"
        case .cash: return "\(hub) account → \(appState.member(transfer.ledger ?? .partner).possessive) cash"
        }
    }

    @ViewBuilder private var transfers: some View {
        if !plan.transfers.isEmpty {
            let done = plan.transfers.filter(\.done).count
            LabelledCard(label: "Payday transfers", trailingText: "\(done) of \(plan.transfers.count) done") {
                VStack(spacing: 0) {
                    ProgressTrack(fraction: Double(done) / Double(plan.transfers.count))
                        .padding(.bottom, Spacing.sm)
                    ForEach(plan.transfers) { transfer in
                        Button { toggle(transfer) } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: transfer.done ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(transfer.done ? Color.storPositive : Color.storTertiaryLabel)
                                Text(transferTitle(transfer)).storText(14).foregroundStyle(Color.storInk)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                MonoText(money(transfer.amount), size: 13)
                            }
                            .frame(minHeight: 44)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(transfer.done ? .isSelected : [])
                    }
                    Text(plan.stays < 0
                         ? "⚠️ \(appState.member(plan.hub).firstName) is short by \(money(-plan.stays))"
                         : "\(appState.member(plan.hub).firstName) keeps \(money(plan.stays)) as their cash account")
                        .storText(13)
                        .foregroundStyle(plan.stays < 0 ? Color.storNegative : Color.storSecondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.xs)
                }
            }
        }
    }

    private func toggle(_ transfer: BudgetPlan.Transfer) {
        appState.setTransfer(transfer.key, done: !transfer.done, month: plan.month)
        if offset != 0, let i = browsed?.transfers.firstIndex(where: { $0.key == transfer.key }) {
            browsed?.transfers[i].done.toggle()
        }
    }

    @ViewBuilder private var whereItGoes: some View {
        if !plan.groups.isEmpty {
            let largest = plan.groups.map(\.amount).max() ?? 1
            LabelledCard(label: "Where the money goes") {
                VStack(spacing: Spacing.sm) {
                    ForEach(plan.groups) { row in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(row.name).storText(14)
                                Spacer()
                                MonoText("\(money(row.amount)) · \(share(row.amount).replacingOccurrences(of: " of income", with: ""))", size: 12)
                            }
                            ProgressTrack(fraction: row.amount / largest)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    @ViewBuilder private var split: some View {
        if !plan.split.isEmpty && plan.income > 0 {
            LabelledCard(label: "50/30/20 check") {
                VStack(spacing: Spacing.md) {
                    ForEach(plan.split) { row in
                        let tint: Color = switch row.status {
                        case .over: .storNegative
                        case .left: .storLimeInk
                        case .spare: .storPositive
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(row.category.title).storText(14, weight: .semibold)
                                Spacer()
                                Text(status(row)).storText(13).foregroundStyle(tint)
                            }
                            ProgressTrack(fraction: row.actual > 0 ? row.using / row.actual : 1, fill: tint)
                            MonoText("Using \(money(row.using)) of \(money(row.actual)) · target \(money(row.allocated))",
                                     size: 11, color: .storTertiaryLabel)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    Text("Discretionary gives up any essential overspend, and saving gets discretionary’s spare.")
                        .storText(12).foregroundStyle(Color.storSecondaryLabel)
                }
            }
        }
    }

    private func status(_ row: BudgetPlan.Split) -> String {
        switch row.status {
        case .over: "\(money(row.difference)) over"
        case .left: "\(money(row.difference)) left"
        case .spare: "\(money(row.difference)) spare"
        }
    }

    @ViewBuilder private var biggest: some View {
        if !plan.biggest.isEmpty {
            LabelledCard(label: "Biggest bills") {
                VStack(spacing: Spacing.xs) {
                    ForEach(plan.biggest) { bill in
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(bill.name).storText(14)
                                MonoText(bill.group, size: 11, color: .storTertiaryLabel)
                            }
                            Spacer()
                            MonoText(money(bill.amount), size: 13)
                        }
                        .frame(minHeight: 40)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    @ViewBuilder private var cashAccounts: some View {
        if !plan.cashAccounts.isEmpty && plan.income > 0 {
            LabelledCard(label: "Cash accounts") {
                VStack(spacing: Spacing.sm) {
                    ForEach(plan.cashAccounts) { account in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(appState.member(account.ledger).displayName).storText(14, weight: .semibold)
                                MonoText("\(money(account.allowance)) less \(money(account.personalBills)) personal bills",
                                         size: 11, color: .storTertiaryLabel)
                            }
                            Spacer()
                            MonoText("\(money(account.left)) left", size: 13,
                                     color: account.left < 0 ? .storNegative : .storInk)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    @ViewBuilder private var forecast: some View {
        if !plan.forecast.isEmpty && plan.income > 0 {
            LabelledCard(label: "Next 12 months") {
                VStack(spacing: 0) {
                    ForEach(Array(plan.forecast.enumerated()), id: \.element.id) { index, month in
                        RowSeparator(isVisible: index > 0)
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(forecastMonth(month.month)).storText(14, weight: .semibold)
                                Spacer()
                                MonoText("\(money(month.cashEach)) each\(month.isShort ? " ⚠️" : "")", size: 12,
                                         color: month.isShort ? .storNegative : .storInk)
                            }
                            MonoText("Bills \(money(month.bills)) · pots \(money(month.potsAndSavings)) · invest \(money(month.addInvesting))",
                                     size: 11, color: .storTertiaryLabel)
                            if !month.extraBills.isEmpty {
                                Text("Also: \(month.extraBills.joined(separator: ", "))")
                                    .storText(12).foregroundStyle(Color.storSecondaryLabel)
                            }
                        }
                        .padding(.vertical, Spacing.xs)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    private func forecastMonth(_ key: String) -> String {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return key }
        return "\(MonthCalendar.monthAbbreviation(parts[1])) \(parts[0])"
    }
}

#if DEBUG
#Preview {
    NavigationStack { PlanView() }.environment(AppState.preview)
}
#endif
