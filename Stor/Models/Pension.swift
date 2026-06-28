import Foundation

struct Pension: Identifiable {
    let id: UUID
    var memberID: UUID
    var memberName: String
    var currentValue: Double
    var target: Double
    var lastUpdated: Date

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(currentValue / target, 1.0)
    }
}
