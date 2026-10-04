import SwiftUI

/// The month's committed payments, on a calendar and then as a list.
struct BillsView: View {
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "September bills") { dismiss() }

            ScrollView {
                VStack(spacing: Spacing.md) {
                    if !typeSize.isAccessibilitySize { BillCalendar() }

                    RowCard {
                        ForEach(Array(MockData.bills.enumerated()), id: \.element.id) { index, bill in
                            row(bill, isFirst: index == 0)
                        }
                    }
                }
                .screenInset()
                .padding(.top, Spacing.xxs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func row(_ bill: Bill, isFirst: Bool) -> some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            AdaptiveStack(spacing: 13) {
                VStack(spacing: 0) {
                    MonoText("\(bill.day)", size: 15,
                             color: isImminent(bill) ? .storNegative : .storInk)
                    MonoLabel("Sep", size: 9, tracking: 0.08, color: .storQuaternaryLabel)
                }
                .frame(width: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(bill.name)
                        .storText(14.5)
                        .tracking(-0.116)
                        .foregroundStyle(Color.storInk)
                    MonoText(bill.meta, size: 11, color: .storTertiaryLabel)
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
        bill.day >= MockData.todayDay && bill.day <= MockData.todayDay + 4
    }
}

/// A month grid marking today and every day a bill lands on.
struct BillCalendar: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xxs), count: 7)

    private var billDays: Set<Int> { Set(MockData.bills.map(\.day)) }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            LazyVGrid(columns: columns, spacing: Spacing.xxs) {
                ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, name in
                    MonoLabel(name, size: 9.5, tracking: 0.06, color: .storQuaternaryLabel)
                }
            }

            LazyVGrid(columns: columns, spacing: Spacing.xxs) {
                ForEach(0..<MockData.monthStartOffset, id: \.self) { _ in
                    Color.clear.frame(height: 40).accessibilityHidden(true)
                }
                ForEach(1...MockData.daysInMonth, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
        .padding(Spacing.lg)
        .storCard(radius: Radius.xl)
    }

    private func dayCell(_ day: Int) -> some View {
        let isToday = day == MockData.todayDay
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
        .accessibilityLabel("September \(day)\(isToday ? ", today" : "")\(hasBill ? ", bill due" : "")")
        .background(cellFill(hasBill: hasBill, isToday: isToday))
        .clipShape(.rect(cornerRadius: Radius.xs, style: .continuous))
    }

    /// Days already gone recede; today inverts.
    private func dayColor(_ day: Int, isToday: Bool) -> Color {
        if isToday { return .storBackground }
        return day < MockData.todayDay ? .storTertiaryLabel : .storInk
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

#Preview {
    BillsView().environment(AppState())
}
