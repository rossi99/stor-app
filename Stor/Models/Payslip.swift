import Foundation

/// Expected net = gross − income tax − National Insurance, checked against what
/// actually landed. The discrepancy is the point of the whole screen.
struct Payslip: Identifiable, Hashable, Sendable {
    let id = UUID()
    let ledger: Ledger
    let name: String
    let gross: Double
    let tax: Double
    let nationalInsurance: Double
    let received: Double
    let expected: Double
    let note: String

    var shortfall: Double { expected - received }

    /// Anything inside a penny either way reads as correct.
    var isAsExpected: Bool { abs(shortfall) < 0.01 }
}
