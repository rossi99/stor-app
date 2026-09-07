import Foundation

/// One line in the ledger.
struct Transaction: Identifiable, Hashable, Sendable {
    let id = UUID()
    /// Day heading this row groups under — "Today · Mon 14 Sep".
    let group: String
    let title: String
    let category: String
    /// Negative for spending, positive for money in.
    let amount: Double
    /// Who initiated it. `nil` means a direct debit with no human behind it.
    let actor: Ledger?
    /// Which ledger it settles against.
    let ledger: Ledger
    /// How the cost was borne — "Joint", "50/50", "Ana".
    let tag: String
    /// Two-character monogram for the row chip.
    let monogram: String
    /// Freshly added this session, so the row flashes in.
    var isNew: Bool = false

    var isIncome: Bool { amount > 0 }

    /// "Groceries · Ana", "Energy & water · Direct debit".
    var subtitle: String {
        let by = actor.map { $0 == .ana ? "Ana" : "Sam" } ?? "Direct debit"
        return "\(category) · \(by)"
    }
}
