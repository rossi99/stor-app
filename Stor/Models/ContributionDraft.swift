import Foundation

/// Keeps incomplete edits out of household balances until the user saves.
struct ContributionDraft {
    var entries: [Ledger: String]
    private let original: [Ledger: Double]

    init(members: [HouseholdMember]) {
        original = Dictionary(uniqueKeysWithValues: members.map { ($0.ledger, $0.contribution) })
        entries = original.mapValues(MoneyInput.entry(for:))
    }

    var values: [Ledger: Double]? {
        var result: [Ledger: Double] = [:]
        for ledger in original.keys {
            guard let amount = MoneyInput.amount(from: entries[ledger] ?? "") else { return nil }
            result[ledger] = amount
        }
        return result
    }

    var isValid: Bool { values != nil }
    var hasChanges: Bool { values != original }
    var total: Double? { values.map { $0.values.reduce(0, +) } }

    mutating func adjust(_ ledger: Ledger, by delta: Double) {
        guard original[ledger] != nil, delta.isFinite,
              let current = MoneyInput.amount(from: entries[ledger] ?? "") else { return }
        let next = min(MoneyInput.maximum, max(0, current + delta))
        entries[ledger] = MoneyInput.entry(for: (next * 100).rounded() / 100)
    }
}
