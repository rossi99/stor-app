import SwiftUI

/// The month's committed payments, on a calendar and then as a list.
struct BillsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showsNewBill = false

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "\(appState.month.monthName) bills") { dismiss() }

            if appState.snapshot.bills.isEmpty {
                ContentUnavailableView {
                    Label("No bills yet", systemImage: "calendar")
                } description: {
                    Text("Shared bills will show here before they leave the pot.")
                } actions: {
                    CreateButton(title: "Add a bill") { showsNewBill = true }
                }
            } else {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    if !typeSize.isAccessibilitySize { BillCalendar() }

                    RowCard {
                        ForEach(Array(appState.snapshot.bills.enumerated()), id: \.element.id) { index, bill in
                            row(bill, isFirst: index == 0)
                        }
                    }

                    CreateButton(title: "Add a bill") { showsNewBill = true }
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
        .sheet(isPresented: $showsNewBill) { NewBillSheet() }
    }

    private func row(_ bill: Bill, isFirst: Bool) -> some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            AdaptiveStack(spacing: 13) {
                VStack(spacing: 0) {
                    MonoText("\(MonthCalendar.day(of: bill.dueDate))", size: 15,
                             color: isImminent(bill) ? .storNegative : .storInk)
                    MonoLabel(MonthCalendar.format(bill.dueDate, "MMM"), size: 9, tracking: 0.08, color: .storQuaternaryLabel)
                }
                .frame(width: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(bill.name)
                        .storText(14.5)
                        .tracking(-0.116)
                        .foregroundStyle(Color.storInk)
                    if !bill.meta.isEmpty {
                        MonoText(bill.meta, size: 11, color: .storTertiaryLabel)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                MonoText(money(bill.amount), size: 13.5,
                         color: bill.isEstimated ? .storTertiaryLabel : .storInk)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
        }
    }

    /// Within four days of today, so it warrants the warning colour.
    private func isImminent(_ bill: Bill) -> Bool {
        bill.dueDate >= appState.month.startOfToday()
            && bill.dueDate < MonthCalendar(date: appState.month.startOfToday()).adding(days: 5)
    }
}

/// A month grid marking today and every day a bill lands on.
struct BillCalendar: View {
    @Environment(AppState.self) private var appState
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xxs), count: 7)

    private var month: MonthCalendar { appState.month }

    private var billDays: Set<Int> {
        Set(appState.snapshot.bills.filter { month.isSameMonth($0.dueDate) }.map { MonthCalendar.day(of: $0.dueDate) })
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
