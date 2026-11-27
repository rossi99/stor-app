import Foundation

/// The household's budget sheet rules: 50/30/20 targets, a monthly loan allocation and a per-person cash cap.
struct BudgetSettings: Codable, Equatable, Sendable {
    var essentialPct: Int
    var discretionaryPct: Int
    var savingPct: Int
    var loanAllocation: Double
    /// Nil means everything left after bills is split as cash.
    var cashCap: Double?

    static let standard = BudgetSettings(essentialPct: 50, discretionaryPct: 30, savingPct: 20, loanAllocation: 0, cashCap: nil)
}

/// One budget month as the server works it out. Money is in major units.
struct BudgetPlan: Codable, Equatable, Sendable {
    struct Row: Codable, Equatable, Sendable, Identifiable {
        let name: String
        let amount: Double
        var id: String { name }
    }

    struct Transfer: Codable, Equatable, Sendable, Identifiable {
        enum Kind: String, Codable, Sendable { case payIn, pot, investing, cash }
        let key: String
        let kind: Kind
        /// Who pays in, or whose cash account receives.
        let ledger: Ledger?
        /// The pot or investment receiving.
        let group: String?
        let amount: Double
        var done: Bool
        var id: String { key }
    }

    struct Split: Codable, Equatable, Sendable, Identifiable {
        enum Status: String, Codable, Sendable { case over, left, spare }
        let category: Bill.Category
        let allocated: Double
        let actual: Double
        let using: Double
        let status: Status
        var id: Bill.Category { category }
        /// What is over, or still left, against the actual allowance.
        var difference: Double { abs(actual - using) }
    }

    struct Biggest: Codable, Equatable, Sendable, Identifiable {
        let id: String
        let name: String
        let group: String
        let amount: Double
    }

    struct CashAccount: Codable, Equatable, Sendable, Identifiable {
        let ledger: Ledger
        let allowance: Double
        let personalBills: Double
        let left: Double
        var id: Ledger { ledger }
    }

    struct ForecastMonth: Codable, Equatable, Sendable, Identifiable {
        let month: String
        let bills: Double
        let potsAndSavings: Double
        let addInvesting: Double
        let cashEach: Double
        let extraBills: [String]
        let isShort: Bool
        var id: String { month }
    }

    /// "2026-12".
    var month: String
    /// The ledger whose account receives pay and sends every transfer.
    var hub: Ledger
    var settings: BudgetSettings
    var income: Double
    var loanRepayments: Double
    var loanOverpay: Double
    var fixedInvesting: Double
    var addInvesting: Double
    var billsAndPots: Double
    var cashEach: Double
    /// What the hub keeps after every transfer; negative means short.
    var stays: Double
    /// Joint bills and your own cash-account bills.
    var bills: [Bill]
    /// Where the money goes, largest first.
    var groups: [Row]
    var transfers: [Transfer]
    var split: [Split]
    var biggest: [Biggest]
    var cashAccounts: [CashAccount]
    var forecast: [ForecastMonth]

    var invested: Double { fixedInvesting + addInvesting }

    static func empty(month: String) -> BudgetPlan {
        BudgetPlan(month: month, hub: .you, settings: .standard, income: 0, loanRepayments: 0, loanOverpay: 0,
                   fixedInvesting: 0, addInvesting: 0, billsAndPots: 0, cashEach: 0, stays: 0, bills: [], groups: [],
                   transfers: [], split: [], biggest: [], cashAccounts: [], forecast: [])
    }

    /// The month key the API expects for the device's month containing `date`.
    static func key(for date: Date) -> String { MonthCalendar.format(date, "yyyy-MM") }
}
