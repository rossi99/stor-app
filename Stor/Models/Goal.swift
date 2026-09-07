import Foundation

/// A shared savings goal with an adjustable monthly contribution.
struct Goal: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let saved: Double
    let target: Double
    /// Adjusted in £50 steps from the goal card.
    var monthly: Double
    let note: String

    static let step: Double = 50
    static let minimumMonthly: Double = 50

    var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1, saved / target)
    }

    var percent: Int { Int((fraction * 100).rounded()) }

    var remaining: Double { max(0, target - saved) }

    /// Months still needed at the current contribution.
    var monthsToGo: Int {
        guard monthly > 0 else { return .max }
        return Int((remaining / monthly).rounded(.up))
    }
}
