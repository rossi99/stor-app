import Foundation

/// A recurring bill from the household's budget, paid from the joint pots or one person's cash account.
struct Bill: Identifiable, Hashable, Codable, Sendable {
    enum Kind: String, CaseIterable, Codable, Sendable {
        case bill, pot, loan, saving, investment

        var title: String {
            switch self {
            case .bill: "Bill"
            case .pot: "Spending pot"
            case .loan: "Loan"
            case .saving: "Savings pot"
            case .investment: "Investment"
            }
        }
    }

    enum Category: String, CaseIterable, Codable, Sendable {
        case essential, discretionary, saving

        var title: String { rawValue.capitalized }
    }

    enum Frequency: String, CaseIterable, Codable, Sendable {
        case monthly, weekly, quarterly, yearly

        var title: String { rawValue.capitalized }
    }

    var id = UUID().uuidString
    var name: String
    /// The pot the money goes to, such as "Household & utilities". Empty for cash-account bills.
    var group: String
    var kind: Kind
    var category: Category
    var amount: Double
    var frequency: Frequency
    /// Months 1 to 12 the full amount lands in; empty means every month.
    var months: [Int]
    /// `joint`, or the ledger whose cash account pays it.
    var paidFrom: Ledger
    var dueDay: Int?
    /// "Camden · direct debit".
    var meta: String
    /// Estimated rather than confirmed, so it renders muted.
    var isEstimated: Bool
    /// What lands in the plan's month, worked out by the server; ignored when saving.
    var thisMonth: Double

    var isPersonal: Bool { paidFrom != .joint }

    /// "Weekly", "Jan, Jul", or "Monthly".
    var cadence: String {
        guard !months.isEmpty else { return frequency.title }
        return months.map { MonthCalendar.monthAbbreviation($0) }.joined(separator: ", ")
    }

    /// The day it leaves in `month`, with a day past the month's end landing on its last day.
    func dueDate(in month: MonthCalendar) -> Date? {
        guard let dueDay else { return nil }
        return month.date(onDay: min(dueDay, month.daysInMonth))
    }
}
