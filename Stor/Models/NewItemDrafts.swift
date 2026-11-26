import Foundation

/// A shared goal being created. Nothing saved yet counts as £0.
struct GoalDraft {
    var name = ""
    var target = ""
    var saved = ""
    var monthly = ""

    var hasContent: Bool { !(name + target + saved + monthly).trimmingCharacters(in: .whitespaces).isEmpty }

    func goal(id: String = UUID().uuidString) -> Goal? {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty,
              let target = MoneyInput.amount(from: target), target > 0,
              let saved = saved.isEmpty ? 0 : MoneyInput.amount(from: saved),
              let monthly = MoneyInput.amount(from: monthly) else { return nil }
        return Goal(id: id, name: title, saved: saved, target: target, monthly: monthly, note: "")
    }
}

/// A monthly budget for one spending category on one ledger.
struct EnvelopeDraft {
    var category: String
    var budget = ""

    var amount: Double? { MoneyInput.amount(from: budget).flatMap { $0 > 0 ? $0 : nil } }
}

/// A bill being added to the joint pot.
struct BillDraft {
    var name = ""
    var amount = ""
    var dueDay = Date()
    var isEstimated = false

    var hasContent: Bool { !(name + amount).trimmingCharacters(in: .whitespaces).isEmpty }

    /// The contract sends date-only values as 12:00 UTC so every timezone shows the same day.
    var dueDate: Date {
        let day = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: dueDay)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        return utc.date(from: DateComponents(year: day.year, month: day.month, day: day.day, hour: 12)) ?? dueDay
    }

    func bill(id: String = UUID().uuidString) -> Bill? {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, let amount = MoneyInput.amount(from: amount), amount > 0 else { return nil }
        return Bill(id: id, dueDate: dueDate, name: title, meta: isEstimated ? "Estimated" : "", amount: amount,
                    isEstimated: isEstimated)
    }
}
