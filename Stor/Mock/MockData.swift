import Foundation

/// Fixtures for the Whitfield–Okonkwo household: Ana and Sam, no kids, GBP.
/// Two salaries paid on the 10th; the joint pot is funded by standing order
/// rather than by splitting each purchase after the fact.
enum MockData {

    // MARK: - People

    static let members: [HouseholdMember] = [
        HouseholdMember(ledger: .ana, name: "Ana Whitfield", initials: "AW",
                        role: "Owner · sees joint + own", netPay: 3341, contribution: 1950),
        HouseholdMember(ledger: .sam, name: "Sam Okonkwo", initials: "SO",
                        role: "Member · sees joint + own", netPay: 2605, contribution: 1450),
    ]

    static let householdName = "Whitfield–Okonkwo"
    static let today = "Mon 14 Sep"
    static let todayDay = 14
    static let daysLeftInMonth = 17

    /// Average monthly shared outgoings — the bar the joint pot has to clear.
    static let averageSharedOutgoings: Double = 3228

    // MARK: - Setup

    static let linkableAccounts: [BankAccount] = [
        BankAccount(id: "monzo",    name: "Monzo Current",    owner: "Ana",   ledger: .ana,   initial: "M"),
        BankAccount(id: "vanguard", name: "Vanguard ISA",     owner: "Ana",   ledger: .ana,   initial: "V"),
        BankAccount(id: "starling", name: "Starling Joint",   owner: "Joint", ledger: .joint, initial: "S"),
        BankAccount(id: "chase",    name: "Chase Saver",      owner: "Joint", ledger: .joint, initial: "C"),
        BankAccount(id: "lloyds",   name: "Lloyds Current",   owner: "Sam",   ledger: .sam,   initial: "L"),
        BankAccount(id: "halifax",  name: "Halifax Mortgage", owner: "Joint", ledger: .joint, initial: "H"),
    ]

    static let defaultLinkedAccounts: Set<String> = ["monzo", "starling", "lloyds"]

    /// Identities that already have an account. Ana's Google address is seeded
    /// so the provider flow demonstrates both halves of the upsert.
    static let knownAccounts: Set<String> = ["ana.whitfield@gmail.com"]

    // MARK: - Envelopes

    static func envelopes(for ledger: Ledger) -> [Envelope] {
        switch ledger {
        case .joint:
            [
                Envelope(name: "Rent & mortgage", spent: 1420, budget: 1420, detail: "Paid 1 Sep",        pace: "on plan"),
                Envelope(name: "Groceries",       spent:  412, budget:  520, detail: "11 shops",          pace: "2% ahead"),
                Envelope(name: "Energy & water",  spent:  188, budget:  210, detail: "2 direct debits",   pace: "on plan"),
                Envelope(name: "Transport",       spent:   96, budget:  160, detail: "TfL + fuel",        pace: "18% under"),
                Envelope(name: "Eating out",      spent:  143, budget:  120, detail: "6 outings",         pace: "over by 19%"),
                Envelope(name: "Home & repairs",  spent:   58, budget:  150, detail: "Screwfix, filters", pace: "61% left"),
                Envelope(name: "Subscriptions",   spent:   47, budget:   48, detail: "7 active",          pace: "on plan"),
                Envelope(name: "Savings transfer", spent: 600, budget:  600, detail: "Auto, 30 Sep",      pace: "on plan"),
            ]
        case .ana:
            [
                Envelope(name: "Clothes",         spent: 118, budget: 150, detail: "3 orders",       pace: "21% left"),
                Envelope(name: "Coffee & lunch",  spent:  86, budget:  90, detail: "19 taps",        pace: "tight"),
                Envelope(name: "Hobbies",         spent:  64, budget: 200, detail: "Pottery studio", pace: "68% left"),
                Envelope(name: "Gifts",           spent:  35, budget:  60, detail: "Sam's mum",      pace: "42% left"),
                Envelope(name: "Unallocated",     spent:  80, budget: 200, detail: "No envelope",    pace: "—"),
            ]
        case .sam:
            [
                Envelope(name: "Cycling",         spent: 214, budget: 180, detail: "New wheelset", pace: "over by 19%"),
                Envelope(name: "Coffee & lunch",  spent: 102, budget:  90, detail: "24 taps",      pace: "over by 13%"),
                Envelope(name: "Games",           spent:  76, budget:  80, detail: "2 titles",     pace: "tight"),
                Envelope(name: "Barber",          spent:  30, budget:  40, detail: "1 visit",      pace: "25% left"),
                Envelope(name: "Unallocated",     spent:  90, budget: 310, detail: "No envelope",  pace: "—"),
            ]
        }
    }

    // MARK: - Ledger

    static let transactions: [Transaction] = [
        Transaction(group: "Today · Mon 14 Sep", title: "Sainsbury's", category: "Groceries",
                    amount: -46.20, actor: .ana, ledger: .joint, tag: "Joint", monogram: "SB"),
        Transaction(group: "Today · Mon 14 Sep", title: "TfL travel", category: "Transport",
                    amount: -6.80, actor: .sam, ledger: .joint, tag: "Joint", monogram: "TF"),
        Transaction(group: "Sun 13 Sep", title: "The Bell", category: "Eating out",
                    amount: -38.50, actor: .sam, ledger: .joint, tag: "50/50", monogram: "BE"),
        Transaction(group: "Sun 13 Sep", title: "Boots", category: "Health",
                    amount: -12.40, actor: .ana, ledger: .ana, tag: "Ana", monogram: "BO"),
        Transaction(group: "Sat 12 Sep", title: "Ocado", category: "Groceries",
                    amount: -74.15, actor: .ana, ledger: .joint, tag: "Joint", monogram: "OC"),
        Transaction(group: "Sat 12 Sep", title: "Screwfix", category: "Home & repairs",
                    amount: -21.90, actor: .sam, ledger: .joint, tag: "60/40", monogram: "SX"),
        Transaction(group: "Sat 12 Sep", title: "Ozone Coffee", category: "Coffee & lunch",
                    amount: -3.60, actor: .ana, ledger: .ana, tag: "Ana", monogram: "OZ"),
        Transaction(group: "Fri 11 Sep", title: "Octopus Energy", category: "Energy & water",
                    amount: -142, actor: nil, ledger: .joint, tag: "DD", monogram: "OE"),
        Transaction(group: "Fri 11 Sep", title: "Deliveroo", category: "Eating out",
                    amount: -29.40, actor: .sam, ledger: .joint, tag: "50/50", monogram: "DL"),
        Transaction(group: "Thu 10 Sep", title: "Transfer to joint pot", category: "Contribution",
                    amount: -1950, actor: .ana, ledger: .ana, tag: "Ana", monogram: "→"),
        Transaction(group: "Thu 10 Sep", title: "Salary · Kite Studio", category: "Income",
                    amount: 3341.28, actor: .ana, ledger: .ana, tag: "Ana", monogram: "£"),
    ]

    static let spendCategories = [
        "Groceries", "Eating out", "Transport", "Home & repairs", "Health", "Other",
    ]

    // MARK: - Goals

    static let goals: [Goal] = [
        Goal(id: "kitchen", name: "Kitchen renovation", saved: 7400, target: 18000, monthly: 450,
             note: "Funded from the joint pot after the savings transfer."),
        Goal(id: "japan", name: "Japan, spring", saved: 2340, target: 6000, monthly: 150,
             note: "Split 50/50 from personal allowances, not the pot."),
    ]

    static let emergencyFundMonths = 4.2
    static let emergencyFundNote =
        "Target is 6 months. At £600/mo you reach it in November 2027."
}
