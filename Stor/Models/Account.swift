import SwiftUI

/// One holding in the net-worth breakdown. Liabilities carry a negative value.
struct Account: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    /// "Current account", "Stocks & shares", "2.1% to Mar 2028".
    let kind: String
    let value: Double

    var isLiability: Bool { value < 0 }
}

/// Accounts grouped by who they belong to, plus a group for what is owed.
struct AccountGroup: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    /// `nil` for the liabilities group, which belongs to no one person.
    let ledger: Ledger?
    let accounts: [Account]

    var total: Double { accounts.reduce(0) { $0 + $1.value } }

    var dot: Color { ledger?.accent ?? .storNegative }
    var headerFill: Color { ledger?.soft ?? .storNegativeSoft }
}
