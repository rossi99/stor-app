import SwiftUI
import Charts

/// Dated values with an explicit scale and native chart accessibility.
struct Sparkline: View {
    let points: [NetWorthPoint]
    var range: NetWorthRange = .oneYear
    @Environment(\.money) private var money
    @State private var selectedDate: Date?

    private var selectedPoint: NetWorthPoint? {
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
                    Text("\(point.date.formatted(date: .abbreviated, time: .omitted)) · \(money(point.value))")
                        .font(.headline)
                } else {
                    Text("Touch and hold to explore values")
                        .font(.footnote).foregroundStyle(Color.storSecondaryLabel)
                }
                Chart(points) { point in
                    LineMark(x: .value("Date", point.date), y: .value("Net worth", point.value))
                        .foregroundStyle(Color.storAccent)
                        .accessibilityLabel(point.date.formatted(date: .abbreviated, time: .omitted))
                        .accessibilityValue(money(point.value))
                    if let selectedPoint, selectedPoint.id == point.id {
                        RuleMark(x: .value("Selected date", point.date))
                            .foregroundStyle(Color.storSecondaryLabel)
                        PointMark(x: .value("Date", point.date), y: .value("Net worth", point.value))
                            .foregroundStyle(Color.storAccent)
                    }
                }
                .chartYScale(domain: ((points.map(\.value).min() ?? 0) - 1000)...((points.map(\.value).max() ?? 0) + 1000))
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) { Text(money.thousands(amount)) }
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
                    Text("\(first.date.formatted(date: .abbreviated, time: .omitted)): \(money(first.value)) → \(last.date.formatted(date: .abbreviated, time: .omitted)): \(money(last.value))")
                        .font(.footnote).foregroundStyle(Color.storSecondaryLabel)
                }
            }
            .onChange(of: range) { selectedDate = nil }
        }
    }
}
