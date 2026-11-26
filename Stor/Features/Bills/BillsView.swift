import SwiftUI

/// The household's recurring bills, by pot, with what lands this month.
struct BillsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var editing: BillDraft?

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "\(appState.month.monthName) bills") { dismiss() }

            if appState.plan.bills.isEmpty {
                ContentUnavailableView {
                    Label("No bills yet", systemImage: "calendar")
                } description: {
                    Text("Add each bill, pot and saving once. Stór works out what lands each month.")
                } actions: {
                    CreateButton(title: "Add a bill") { editing = BillDraft() }
                }
            } else {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    if !typeSize.isAccessibilitySize && appState.plan.bills.contains(where: { $0.dueDay != nil }) {
                        BillCalendar()
                    }

                    ForEach(appState.billGroups, id: \.name) { group in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack {
                                MonoLabel(group.name, size: 10.5, tracking: 0.12, color: .storTertiaryLabel)
                                Spacer()
                                MonoText(money(group.total), size: 12, color: .storSecondaryLabel)
                            }
                            .padding(.horizontal, Spacing.xs)
                            .accessibilityElement(children: .combine)
                            RowCard {
                                ForEach(Array(group.bills.enumerated()), id: \.element.id) { index, bill in
                                    row(bill, isFirst: index == 0)
                                }
                            }
                        }
                    }

                    CreateButton(title: "Add a bill") { editing = BillDraft() }
                }
                .screenInset()
                .padding(.top, Spacing.xxs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
            }
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $editing) { draft in NewBillSheet(draft: draft) }
    }

    private func row(_ bill: Bill, isFirst: Bool) -> some View {
        let due = bill.dueDate(in: appState.month)
        return VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            Button { editing = BillDraft(bill) } label: {
                AdaptiveStack(spacing: 13) {
                    VStack(spacing: 0) {
                        if let due {
                            MonoText("\(MonthCalendar.day(of: due))", size: 15,
                                     color: isImminent(due) ? .storNegative : .storInk)
                            MonoLabel(MonthCalendar.format(due, "MMM"), size: 9, tracking: 0.08, color: .storQuaternaryLabel)
                        } else {
                            MonoLabel("—", size: 12, tracking: 0, color: .storQuaternaryLabel)
                        }
                    }
                    .frame(width: 38)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(bill.name)
                            .storText(14.5)
                            .tracking(-0.116)
                            .foregroundStyle(Color.storInk)
                        MonoText(details(bill), size: 11, color: .storTertiaryLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    MonoText(money(bill.thisMonth), size: 13.5,
                             color: bill.isEstimated || bill.thisMonth == 0 ? .storTertiaryLabel : .storInk)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 14)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Edit this bill")
            .contextMenu {
                Button("Delete", systemImage: "trash", role: .destructive) { appState.deleteBill(bill) }
            }
        }
    }

    /// "£120 weekly · Fuel card", so the this-month figure on the right makes sense.
    private func details(_ bill: Bill) -> String {
        var parts = ["\(money(bill.amount)) \(bill.cadence.lowercased())"]
        if !bill.isPersonal && bill.kind != .bill { parts.append(bill.kind.title) }
        if !bill.meta.isEmpty { parts.append(bill.meta) }
        return parts.joined(separator: " · ")
    }

    /// Within four days of today, so it warrants the warning colour.
    private func isImminent(_ due: Date) -> Bool {
        due >= appState.month.startOfToday()
            && due < MonthCalendar(date: appState.month.startOfToday()).adding(days: 5)
    }
}

/// A month grid marking today and every day a bill lands on.
struct BillCalendar: View {
    @Environment(AppState.self) private var appState
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xxs), count: 7)

    private var month: MonthCalendar { appState.month }

    private var billDays: Set<Int> {
        Set(appState.plan.bills.filter { $0.thisMonth > 0 }.compactMap { $0.dueDate(in: month).map(MonthCalendar.day(of:)) })
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            LazyVGrid(columns: columns, spacing: Spacing.xxs) {
                ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, name in
                    MonoLabel(name, size: 9.5, tracking: 0.06, color: .storQuaternaryLabel)
                }
            }

            LazyVGrid(columns: columns, spacing: Spacing.xxs) {
                // Negative ids so the leading blanks can't collide with day numbers.
                ForEach(-month.startOffset..<0, id: \.self) { _ in
                    Color.clear.frame(height: 40).accessibilityHidden(true)
                }
                ForEach(1...month.daysInMonth, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
        .padding(Spacing.lg)
        .storCard(radius: Radius.xl)
    }

    private func dayCell(_ day: Int) -> some View {
        let isToday = day == month.day
        let hasBill = billDays.contains(day)

        return VStack(spacing: 3) {
            MonoText("\(day)", size: 11.5, color: dayColor(day, isToday: isToday))

            Circle()
                .fill(dotColor(hasBill: hasBill, isToday: isToday))
                .frame(width: 5, height: 5)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(month.monthName) \(day)\(isToday ? ", today" : "")\(hasBill ? ", bill due" : "")")
        .background(cellFill(hasBill: hasBill, isToday: isToday))
        .clipShape(.rect(cornerRadius: Radius.xs, style: .continuous))
    }

    /// Days already gone recede; today inverts.
    private func dayColor(_ day: Int, isToday: Bool) -> Color {
        if isToday { return .storBackground }
        return day < month.day ? .storTertiaryLabel : .storInk
    }

    private func dotColor(hasBill: Bool, isToday: Bool) -> Color {
        guard hasBill else { return .clear }
        return isToday ? .storLime : .storNegative
    }

    private func cellFill(hasBill: Bool, isToday: Bool) -> Color {
        if isToday { return .storAccent }
        return hasBill ? .storBackground : .clear
    }
}

#if DEBUG
#Preview {
    BillsView().environment(AppState.preview)
}
#endif
