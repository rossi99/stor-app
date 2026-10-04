import SwiftUI
import Charts

/// Dated values with an explicit scale and native chart accessibility.
struct Sparkline: View {
    let values: [Double]
    var range: NetWorthRange = .oneYear
    @Environment(\.money) private var money
    @State private var selectedDate: Date?

    private var points: [Point] {
        let end = MockData.referenceDate
        let calendar = Calendar(identifier: .gregorian)
        let start: Date
        switch range {
        case .oneMonth:
            start = calendar.date(from: calendar.dateComponents([.year, .month], from: end))!
        case .sixMonths: start = calendar.date(byAdding: .month, value: -6, to: end)!
        case .oneYear: start = calendar.date(byAdding: .month, value: -12, to: end)!
        case .all: start = calendar.date(byAdding: .year, value: -7, to: end)!
        }
        return values.enumerated().map { index, value in
            Point(id: index, date: start.addingTimeInterval(end.timeIntervalSince(start)
                  * Double(index) / Double(max(1, values.count - 1))), value: value)
        }
    }

    private var selectedPoint: Point? {
        guard let selectedDate else { return nil }
        return points.min { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) }
    }

    var body: some View {
        if money.privacyMode {
            Label("Chart hidden while balances are hidden", systemImage: "eye.slash")
                .font(.body).foregroundStyle(Color.storSecondaryLabel)
                .frame(maxWidth: .infinity, minHeight: 160)
        } else {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                if let point = selectedPoint {
                    Text("\(point.date.formatted(date: .abbreviated, time: .omitted)) · \(money(point.value * 1000))")
                        .font(.headline)
                } else {
                    Text("Touch and hold to explore values")
                        .font(.footnote).foregroundStyle(Color.storSecondaryLabel)
                }
                Chart(points) { point in
                    LineMark(x: .value("Date", point.date), y: .value("Net worth", point.value))
                        .foregroundStyle(Color.storAccent)
                        .accessibilityLabel(point.date.formatted(date: .abbreviated, time: .omitted))
                        .accessibilityValue(money(point.value * 1000))
                    if let selectedPoint, selectedPoint.id == point.id {
                        RuleMark(x: .value("Selected date", point.date))
                            .foregroundStyle(Color.storSecondaryLabel)
                        PointMark(x: .value("Date", point.date), y: .value("Net worth", point.value))
                            .foregroundStyle(Color.storAccent)
                    }
                }
                .chartYScale(domain: ((values.min() ?? 0) - 1)...((values.max() ?? 1) + 1))
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) { Text(money.thousands(amount * 1000)) }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                        AxisValueLabel(format: range == .all ? .dateTime.year() : .dateTime.month(.abbreviated).day())
                    }
                }
                .chartXSelection(value: $selectedDate)
                .frame(height: 180)
                .accessibilityLabel("Household net worth, \(range.caption)")

                if let first = points.first, let last = points.last {
                    Text("\(first.date.formatted(date: .abbreviated, time: .omitted)): \(money(first.value * 1000)) → \(last.date.formatted(date: .abbreviated, time: .omitted)): \(money(last.value * 1000))")
                        .font(.footnote).foregroundStyle(Color.storSecondaryLabel)
                }
            }
            .onChange(of: range) { selectedDate = nil }
        }
    }

    private struct Point: Identifiable {
        let id: Int
        let date: Date
        let value: Double
    }
}
