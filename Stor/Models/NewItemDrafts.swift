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

/// A member's name and take-home pay being edited. Pay left blank counts as nothing yet.
struct MemberDraft: Identifiable, Equatable {
    let ledger: Ledger
    var name: String
    var pay: String

    var id: Ledger { ledger }

    init(_ member: HouseholdMember) {
        ledger = member.ledger
        name = member.name
        pay = member.netPay > 0 ? MoneyInput.entry(for: member.netPay) : ""
    }

    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var netPay: Double? { pay.isEmpty ? 0 : MoneyInput.amount(from: pay) }
    var isValid: Bool { netPay != nil && trimmedName.count <= 60 }

    static func drafts(for members: [HouseholdMember]) -> [MemberDraft] { members.map(MemberDraft.init) }
}

/// A monthly budget for one spending category on one ledger.
struct EnvelopeDraft {
    var category: String
    var budget = ""

    var amount: Double? { MoneyInput.amount(from: budget).flatMap { $0 > 0 ? $0 : nil } }
}

/// A recurring bill being added or edited. "Specific months" is a monthly bill landing only in `months`.
struct BillDraft: Equatable, Identifiable {
    enum Schedule: Hashable { case every(Bill.Frequency), specificMonths }

    var id = UUID().uuidString
    var name = ""
    var amount = ""
    var schedule = Schedule.every(.monthly)
    var months: Set<Int> = []
    var paidFrom = Ledger.joint
    var group = ""
    var kind = Bill.Kind.bill
    var category = Bill.Category.essential
    var dueDay: Int?
    var meta = ""
    var isEstimated = false
    /// Kept from the bill being edited, so its row reads right until the plan reloads.
    private var thisMonth: Double?

    init() {}

    init(_ bill: Bill) {
        id = bill.id
        name = bill.name
        amount = MoneyInput.entry(for: bill.amount)
        schedule = bill.months.isEmpty ? .every(bill.frequency) : .specificMonths
        months = Set(bill.months)
        paidFrom = bill.paidFrom
        group = bill.group
        kind = bill.kind
        category = bill.category
        dueDay = bill.dueDay
        meta = bill.meta
        isEstimated = bill.isEstimated
        thisMonth = bill.thisMonth
    }

    var hasContent: Bool { !(name + amount + group + meta).trimmingCharacters(in: .whitespaces).isEmpty }

    func bill() -> Bill? {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let pot = group.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, title.count <= 100, meta.count <= 100,
              let amount = MoneyInput.amount(from: amount), amount > 0,
              paidFrom != .joint || (!pot.isEmpty && pot.count <= 60),
              schedule != .specificMonths || !months.isEmpty,
              dueDay.map({ (1...31).contains($0) }) ?? true else { return nil }
        let frequency: Bill.Frequency = if case .every(let f) = schedule { f } else { .monthly }
        // Cash-account bills sit outside the pots and the 50/30/20 split.
        let personal = paidFrom != .joint
        return Bill(id: id, name: title, group: personal ? "" : pot, kind: personal ? .bill : kind,
                    category: personal ? .discretionary : category, amount: amount, frequency: frequency,
                    months: schedule == .specificMonths ? months.sorted() : [], paidFrom: paidFrom, dueDay: dueDay,
                    meta: meta.trimmingCharacters(in: .whitespacesAndNewlines), isEstimated: isEstimated,
                    thisMonth: thisMonth ?? amount)
    }
}
