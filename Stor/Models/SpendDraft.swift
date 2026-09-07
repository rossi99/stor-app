import Foundation

/// The in-progress spend being entered on the add sheet.
struct SpendDraft {
    /// Raw keypad entry, kept as a string so a trailing "." survives typing.
    var entry: String = ""
    var category: String = MockData.spendCategories[0]
    var ledger: Ledger = .joint
    /// Ana's share as a percentage, when the spend settles against the joint pot.
    var splitPercent: Int = 50

    static let splitPresets = [50, 60, 70]
    static let maxEntryLength = 8

    var amount: Double { Double(entry) ?? 0 }
    var isValid: Bool { amount > 0 }

    /// Shows a placeholder zero until the first key lands.
    func display(_ money: MoneyFormatter) -> String {
        money.currency.symbol + (entry.isEmpty ? "0" : entry)
    }

    var showsSplit: Bool { ledger == .joint }

    func anaShare(_ money: MoneyFormatter) -> String {
        money((amount * Double(splitPercent) / 100 * 100).rounded() / 100, decimals: 2)
    }

    func samShare(_ money: MoneyFormatter) -> String {
        money((amount * Double(100 - splitPercent) / 100 * 100).rounded() / 100, decimals: 2)
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
            title: "Card payment · \(category)",
            category: category,
            amount: -amount,
            actor: ledger == .joint ? .ana : ledger,
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
        // TODO(human): decide the input rules and mutate `entry` accordingly.
    }
}
