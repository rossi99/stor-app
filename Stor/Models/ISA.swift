import Foundation

struct ISA: Identifiable {
    let id: UUID
    var memberID: UUID
    var memberName: String
    var type: String
    var balance: Double
    var contributionsThisYear: Double
    var annualAllowance: Double

    var allowanceUsedFraction: Double {
        guard annualAllowance > 0 else { return 0 }
        return min(contributionsThisYear / annualAllowance, 1.0)
    }

    var remainingAllowance: Double {
        max(annualAllowance - contributionsThisYear, 0)
    }
}
