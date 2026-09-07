import Foundation

/// How the household chooses to organise its money. Picked during setup; it
/// decides the shape of everything else.
enum MoneyModel: String, CaseIterable, Identifiable, Sendable {
    case pool, ledgers, split

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pool:    "Everything shared"
        case .ledgers: "Two personal + one joint"
        case .split:   "Split every transaction"
        }
    }

    var summary: String {
        switch self {
        case .pool:
            "One pot, one ledger. Simple, but personal spending is visible to both."
        case .ledgers:
            "Each of you keeps an allowance; shared costs come out of a funded joint pot."
        case .split:
            "No pot. Each spend is apportioned and settled between you monthly."
        }
    }

    /// Short form for the household settings row.
    var settingsLabel: String {
        switch self {
        case .pool:    "Everything shared"
        case .ledgers: "Two + joint"
        case .split:   "Split each spend"
        }
    }
}
