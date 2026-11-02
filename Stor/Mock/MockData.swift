#if DEBUG
import Foundation

/// Debug-only fixtures for the Whitfield–Okonkwo household: Ana and Sam, no kids,
/// GBP. Dates are relative to now so populated screens stay coherent.
enum MockData {

    static var snapshot: HouseholdSnapshot {
        HouseholdSnapshot(
            name: "Whitfield–Okonkwo",
            members: members,
            topUpDay: 10,
            averageSharedOutgoings: 3228,
            ledgers: [
                LedgerSummary(ledger: .joint, available: 180, spent: 2964, committed: 392,
                              unbudgeted: 172, envelopes: envelopes(for: .joint)),
                LedgerSummary(ledger: .you, available: 700, spent: 383, committed: 0,
                              unbudgeted: 0, envelopes: envelopes(for: .you)),
                LedgerSummary(ledger: .partner, available: 700, spent: 512, committed: 0,
                              unbudgeted: 0, envelopes: envelopes(for: .partner)),
            ],
            transactions: transactions,
            goals: goals,
            emergencyFund: EmergencyFund(months: 4.2, note: "Target is 6 months. At £600/mo you reach it in about 14 months."),
            bills: bills,
            netWorth: netWorth,
            accountGroups: accountGroups,
            recaps: recaps,
            payslips: payslips,
            alerts: alerts,
            linkableAccounts: linkableAccounts,
            linkedAccountIDs: ["monzo", "starling", "lloyds"]
        )
    }

    static func daysFromNow(_ days: Int) -> Date {
        MonthCalendar(date: Date()).adding(days: days)
    }

    // MARK: - People

    static let members: [HouseholdMember] = [
        HouseholdMember(ledger: .you, name: "Ana Whitfield", initials: "AW",
                        role: "Owner · sees joint + own", netPay: 3341, contribution: 1950),
        HouseholdMember(ledger: .partner, name: "Sam Okonkwo", initials: "SO",
                        role: "Member · sees joint + own", netPay: 2605, contribution: 1450),
    ]

    // MARK: - Setup

    static let linkableAccounts: [BankAccount] = [
        BankAccount(id: "monzo",    name: "Monzo Current",    owner: "Ana",   ledger: .you,     initial: "M"),
        BankAccount(id: "vanguard", name: "Vanguard ISA",     owner: "Ana",   ledger: .you,     initial: "V"),
        BankAccount(id: "starling", name: "Starling Joint",   owner: "Joint", ledger: .joint,   initial: "S"),
        BankAccount(id: "chase",    name: "Chase Saver",      owner: "Joint", ledger: .joint,   initial: "C"),
        BankAccount(id: "lloyds",   name: "Lloyds Current",   owner: "Sam",   ledger: .partner, initial: "L"),
        BankAccount(id: "halifax",  name: "Halifax Mortgage", owner: "Joint", ledger: .joint,   initial: "H"),
    ]

    // MARK: - Envelopes

    static func envelopes(for ledger: Ledger) -> [Envelope] {
        let envelopes: [Envelope]
        switch ledger {
        case .joint:
            envelopes = [
                Envelope(name: "Rent & mortgage", spent: 1420, budget: 1420, detail: "Paid on the 1st",   pace: "on plan"),
                Envelope(name: "Groceries",       spent:  412, budget:  520, detail: "11 shops",          pace: "2% ahead"),
                Envelope(name: "Energy & water",  spent:  188, budget:  210, detail: "2 direct debits",   pace: "on plan"),
                Envelope(name: "Transport",       spent:   96, budget:  160, detail: "TfL + fuel",        pace: "18% under"),
                Envelope(name: "Eating out",      spent:  143, budget:  120, detail: "6 outings",         pace: "over by 19%"),
                Envelope(name: "Home & repairs",  spent:   58, budget:  150, detail: "Screwfix, filters", pace: "61% left"),
                Envelope(name: "Subscriptions",   spent:   47, budget:   48, detail: "7 active",          pace: "on plan"),
                Envelope(name: "Savings transfer", spent: 600, budget:  600, detail: "Auto, month end",   pace: "on plan"),
            ]
        case .you:
            envelopes = [
                Envelope(name: "Clothes",         spent: 118, budget: 150, detail: "3 orders",       pace: "21% left"),
                Envelope(name: "Coffee & lunch",  spent:  86, budget:  90, detail: "19 taps",        pace: "tight"),
                Envelope(name: "Hobbies",         spent:  64, budget: 200, detail: "Pottery studio", pace: "68% left"),
                Envelope(name: "Gifts",           spent:  35, budget:  60, detail: "Sam's mum",      pace: "42% left"),
                Envelope(name: "Unallocated",     spent:  80, budget: 200, detail: "No envelope",    pace: "—"),
            ]
        case .partner:
            envelopes = [
                Envelope(name: "Cycling",         spent: 214, budget: 180, detail: "New wheelset", pace: "over by 19%"),
                Envelope(name: "Coffee & lunch",  spent: 102, budget:  90, detail: "24 taps",      pace: "over by 13%"),
                Envelope(name: "Games",           spent:  76, budget:  80, detail: "2 titles",     pace: "tight"),
                Envelope(name: "Barber",          spent:  30, budget:  40, detail: "1 visit",      pace: "25% left"),
                Envelope(name: "Unallocated",     spent:  90, budget: 310, detail: "No envelope",  pace: "—"),
            ]
        }
        return envelopes.map {
            Envelope(name: $0.name, spent: $0.spent, budget: $0.budget, detail: $0.detail, pace: $0.pace,
                     threeMonthAverage: ($0.budget * 0.92).rounded())
        }
    }

    // MARK: - Ledger

    static var transactions: [Transaction] {
        [
            Transaction(date: daysFromNow(0), title: "Sainsbury's", category: "Groceries",
                        amount: -46.20, actor: .you, actorName: "Ana", ledger: .joint, tag: "Joint", monogram: "SB"),
            Transaction(date: daysFromNow(0), title: "TfL travel", category: "Transport",
                        amount: -6.80, actor: .partner, actorName: "Sam", ledger: .joint, tag: "Joint", monogram: "TF"),
            Transaction(date: daysFromNow(-1), title: "The Bell", category: "Eating out",
                        amount: -38.50, actor: .partner, actorName: "Sam", ledger: .joint, tag: "50/50", monogram: "BE"),
            Transaction(date: daysFromNow(-1), title: "Boots", category: "Health",
                        amount: -12.40, actor: .you, actorName: "Ana", ledger: .you, tag: "Ana", monogram: "BO"),
            Transaction(date: daysFromNow(-2), title: "Ocado", category: "Groceries",
                        amount: -74.15, actor: .you, actorName: "Ana", ledger: .joint, tag: "Joint", monogram: "OC"),
            Transaction(date: daysFromNow(-2), title: "Screwfix", category: "Home & repairs",
                        amount: -21.90, actor: .partner, actorName: "Sam", ledger: .joint, tag: "60/40", monogram: "SX"),
            Transaction(date: daysFromNow(-2), title: "Ozone Coffee", category: "Coffee & lunch",
                        amount: -3.60, actor: .you, actorName: "Ana", ledger: .you, tag: "Ana", monogram: "OZ"),
            Transaction(date: daysFromNow(-3), title: "Octopus Energy", category: "Energy & water",
                        amount: -142, actor: nil, actorName: nil, ledger: .joint, tag: "DD", monogram: "OE"),
            Transaction(date: daysFromNow(-3), title: "Deliveroo", category: "Eating out",
                        amount: -29.40, actor: .partner, actorName: "Sam", ledger: .joint, tag: "50/50", monogram: "DL"),
            Transaction(date: daysFromNow(-4), title: "Transfer to joint pot", category: "Contribution",
                        amount: -1950, actor: .you, actorName: "Ana", ledger: .you, tag: "Ana", monogram: "→"),
            Transaction(date: daysFromNow(-4), title: "Salary · Kite Studio", category: "Income",
                        amount: 3341.28, actor: .you, actorName: "Ana", ledger: .you, tag: "Ana", monogram: "£"),
        ]
    }

    // MARK: - Goals

    static let goals: [Goal] = [
        Goal(id: "kitchen", name: "Kitchen renovation", saved: 7400, target: 18000, monthly: 450,
             note: "Funded from the joint pot after the savings transfer."),
        Goal(id: "japan", name: "Japan, spring", saved: 2340, target: 6000, monthly: 150,
             note: "Split 50/50 from personal allowances, not the pot."),
    ]
}
#endif
