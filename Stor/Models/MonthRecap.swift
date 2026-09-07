import Foundation

/// A finished month, reviewed on the Recap screen.
struct MonthRecap: Identifiable, Hashable, Sendable {
    /// Short month name — the id and the segment label both come from it.
    let month: String
    let year: Int
    let total: Double
    let budget: Double
    let income: Double
    let saved: Double
    let categories: [RecapCategory]
    /// The single observation worth acting on.
    let takeaway: String

    var id: String { "\(month) \(year)" }

    var isOverBudget: Bool { total > budget }
    var variance: Double { abs(total - budget) }

    /// Savings rate as a share of everything received.
    var savingsRate: Int {
        guard income > 0 else { return 0 }
        return Int(((saved / income) * 100).rounded())
    }

    var largestCategory: Double {
        categories.map(\.amount).max() ?? 0
    }
}

/// One category within a month's recap, with its month-on-month movement.
struct RecapCategory: Identifiable, Hashable, Sendable {
    let name: String
    let amount: Double
    /// Positive means it rose on the previous month.
    let delta: Double

    var id: String { name }

    var isFixed: Bool { delta == 0 }
}
