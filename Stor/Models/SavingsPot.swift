import Foundation

struct SavingsPot: Identifiable {
    let id: UUID
    var name: String
    var current: Double
    var target: Double
    var monthlyContribution: Double
    var emoji: String

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var isComplete: Bool { current >= target }
}
