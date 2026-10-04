import Foundation

/// The in-progress spend being entered on the add sheet.
struct SpendDraft {
    /// Raw decimal input, kept as a string so a trailing separator survives typing.
    var entry: String = ""
    var paidBy: Ledger = .ana
    var merchant = ""
    var category: String = MockData.spendCategories[0]
    var ledger: Ledger = .joint
    /// Ana's share as a percentage, when the spend settles against the joint pot.
    var splitPercent: Int = 50

    static let splitPresets = [0, 50, 100]

    /// Accept either decimal separator, up to six whole digits and two pennies.
    /// Invalid pasted input stays visible in the field, but cannot be committed.
    var amount: Double { MoneyInput.amount(from: entry) ?? 0 }
    var hasContent: Bool {
        !entry.isEmpty || !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isValid: Bool { amount > 0 && (0...100).contains(splitPercent) }
    var anaAmount: Double { (amount * Double(splitPercent)).rounded() / 100 }
    var samAmount: Double { (amount * 100 - anaAmount * 100).rounded() / 100 }

    /// Shows a placeholder zero until the first key lands.
    func display(_ money: MoneyFormatter) -> String {
        money.currency.symbol + (entry.isEmpty ? "0" : entry)
    }

    var showsSplit: Bool { ledger == .joint }

    func anaShare(_ money: MoneyFormatter) -> String {
        money(anaAmount, decimals: 2)
    }

    func samShare(_ money: MoneyFormatter) -> String {
        money(samAmount, decimals: 2)
    }

    /// "60/40" for a joint spend, otherwise the owner's name.
    var tag: String {
        switch ledger {
        case .joint: "\(splitPercent)/\(100 - splitPercent)"
        case .ana:   "Ana"
        case .sam:   "Sam"
        }
    }

    func asTransaction() -> Transaction {
        Transaction(
            group: "Today · \(MockData.today)",
            title: merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Card payment · \(category)" : merchant.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            amount: -amount,
            actor: ledger == .joint ? paidBy : ledger,
            ledger: ledger,
            tag: tag,
            monogram: "✦",
            isNew: true
        )
    }

    /// A key press from the add-sheet keypad.
    enum Key: Hashable {
        case digit(String)
        case decimalPoint
        case delete

        static let layout: [Key] = [
            .digit("1"), .digit("2"), .digit("3"),
            .digit("4"), .digit("5"), .digit("6"),
            .digit("7"), .digit("8"), .digit("9"),
            .decimalPoint, .digit("0"), .delete,
        ]

        var label: String {
            switch self {
            case .digit(let d):  d
            case .decimalPoint:  "."
            case .delete:        "⌫"
            }
        }
    }

    /// Applies one keypad press to `entry`.
    mutating func apply(_ key: Key) {
        switch key {
        case .delete:
            if !entry.isEmpty { entry.removeLast() }
        case .decimalPoint:
            guard !entry.contains("."), !entry.contains(",") else { return }
            entry = entry.isEmpty ? "0." : entry + "."
        case .digit(let digit):
            guard digit.count == 1, "0123456789".contains(digit) else { return }
            let candidate = entry == "0" ? digit : entry + digit
            var copy = self
            copy.entry = candidate
            guard copy.amount > 0 || Double(candidate) == 0 else { return }
            let parts = candidate.replacingOccurrences(of: ",", with: ".")
                .split(separator: ".", omittingEmptySubsequences: false)
            guard (parts.first?.count ?? 0) <= 6,
                  parts.count < 2 || parts[1].count <= 2 else { return }
            entry = candidate
        }
    }
}
