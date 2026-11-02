import Foundation

/// A named spending envelope for the current month.
struct Envelope: Identifiable, Hashable, Codable, Sendable {
    let name: String
    let spent: Double
    let budget: Double
    /// What made up the spend — "11 shops", "TfL + fuel".
    let detail: String
    /// Human read on whether the month is on track — "2% ahead", "over by 19%".
    let pace: String
    /// Three-month average spend, shown when a row is expanded.
    var threeMonthAverage: Double?

    var id: String { name }

    var isOver: Bool { spent > budget }
    var remaining: Double { budget - spent }
    var overspend: Double { spent - budget }

    /// Clamped so an overspent envelope shows a full bar rather than overflowing.
    var fraction: Double {
        guard budget > 0 else { return spent > 0 ? 1 : 0 }
        return min(1, spent / budget)
    }

    /// The right-hand figure: what is left, or what it went over by.
    func rightLabel(_ money: MoneyFormatter) -> String {
        isOver ? "\(money(overspend)) over" : "\(money(remaining)) left"
    }
}
