import Foundation

struct TimeToGoalResult {
    let months: Int
    let isOnTrack: Bool
    let targetDate: Date

    var label: String {
        if months <= 0 { return "Complete" }
        if months == 1 { return "~1 month to target" }
        if months < 12 { return "~\(months) months to target" }
        let years = months / 12
        let rem   = months % 12
        if rem == 0 { return "~\(years)yr to target" }
        return "~\(years)yr \(rem)mo to target"
    }

    var statusLabel: String { isOnTrack ? "on track" : "behind" }
}

func timeToGoal(current: Double, target: Double, monthlyContribution: Double) -> TimeToGoalResult? {
    guard monthlyContribution > 0, current < target else { return nil }
    let monthsNeeded = (target - current) / monthlyContribution
    let months = max(Int(ceil(monthsNeeded)), 0)
    let targetDate = Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
    return TimeToGoalResult(months: months, isOnTrack: true, targetDate: targetDate)
}

func projectedBalances(current: Double, monthlyContribution: Double, months: Int) -> [(month: Int, balance: Double)] {
    (0...months).map { m in
        (month: m, balance: current + Double(m) * monthlyContribution)
    }
}
