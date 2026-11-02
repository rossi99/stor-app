import Foundation

/// One line in the ledger.
struct Transaction: Identifiable, Hashable, Codable, Sendable {
    /// Generated on the device for new spends, so a retried POST can't duplicate.
    var id = UUID().uuidString
    let date: Date
    let title: String
    let category: String
    /// Negative for spending, positive for money in.
    let amount: Double
    /// Who initiated it. `nil` means a direct debit with no human behind it.
    let actor: Ledger?
    /// Display name for `actor`, resolved by whoever created the row.
    let actorName: String?
    /// Which ledger it settles against.
    let ledger: Ledger
    /// How the cost was borne — "Joint", "50/50", "Ana".
    let tag: String
    /// Your share of a joint spend, 0...100. `nil` when it isn't split.
    var splitPercent: Int?
    /// Two-character monogram for the row chip.
    let monogram: String
    /// Freshly added this session, so the row flashes in.
    var isNew: Bool = false

    var isIncome: Bool { amount > 0 }

    private enum CodingKeys: String, CodingKey {
        case id, date, title, category, amount, actor, actorName, ledger, tag, splitPercent, monogram
    }

    /// "Groceries · Ana", "Energy & water · Direct debit".
    var subtitle: String {
        "\(category) · \(actorName ?? "Direct debit")"
    }
}
