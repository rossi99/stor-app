import Foundation

/// One ledger's month. `available` is money in besides contributions: the
/// carry-over for the joint pot, the allowance for a personal ledger.
struct LedgerSummary: Codable, Equatable, Sendable {
    let ledger: Ledger
    let available: Double
    let spent: Double
    /// Bills still to leave this ledger this month.
    let committed: Double
    let unbudgeted: Double
    var envelopes: [Envelope]
}

struct NetWorthPoint: Codable, Equatable, Identifiable, Sendable {
    let date: Date
    let value: Double

    var id: Date { date }
}

struct NetWorth: Codable, Equatable, Sendable {
    let current: Double
    let monthlyChange: Double
    /// Dated points keyed by `NetWorthRange.rawValue`.
    let series: [String: [NetWorthPoint]]
}

struct EmergencyFund: Codable, Equatable, Sendable {
    let months: Double
    let note: String
}

/// Everything the household screens render, as returned by the server.
struct HouseholdSnapshot: Codable, Equatable, Sendable {
    var name: String
    var members: [HouseholdMember]
    var topUpDay: Int
    var averageSharedOutgoings: Double?
    var ledgers: [LedgerSummary]
    var transactions: [Transaction]
    var goals: [Goal]
    var emergencyFund: EmergencyFund?
    var netWorth: NetWorth?
    /// Liabilities are the groups with no ledger.
    var accountGroups: [AccountGroup]
    /// Oldest first.
    var recaps: [MonthRecap]
    var payslips: [Payslip]
    var alerts: [AlertItem]
    var linkableAccounts: [BankAccount]
    var linkedAccountIDs: Set<String>

    /// A brand-new household: two unnamed ledgers either side of an empty pot.
    static let empty = HouseholdSnapshot(
        name: "",
        members: [.placeholder(.you), .placeholder(.partner)],
        topUpDay: 1,
        averageSharedOutgoings: nil,
        ledgers: [],
        transactions: [],
        goals: [],
        emergencyFund: nil,
        netWorth: nil,
        accountGroups: [],
        recaps: [],
        payslips: [],
        alerts: [],
        linkableAccounts: [],
        linkedAccountIDs: []
    )
}
