import Foundation

extension MockData {

    // MARK: - Net worth

    static let netWorth: Double = 233_940
    static let netWorthMonthlyChange: Double = 3180

    /// Net-worth series in thousands, per range.
    static func netWorthSeries(_ range: NetWorthRange) -> [Double] {
        switch range {
        case .oneMonth:  [232.4, 232.6, 233, 233.2, 233.5, 233.7, 233.94]
        case .sixMonths: [228.1, 229.4, 230, 231.2, 232.4, 233.94]
        case .oneYear:   [219.4, 221, 222.3, 223.1, 224.8, 226,
                          227.2, 228.1, 229.4, 230, 231.2, 233.94]
        case .all:       [148, 163, 177, 190, 201, 212, 222, 233.94]
        }
    }

    static let assetGroups: [AccountGroup] = [
        AccountGroup(name: "Ana", ledger: .ana, accounts: [
            Account(name: "Monzo Current", kind: "Current account",  value:  2140),
            Account(name: "Vanguard ISA",  kind: "Stocks & shares",  value: 18400),
            Account(name: "Nest Pension",  kind: "Workplace",        value: 41200),
        ]),
        AccountGroup(name: "Joint", ledger: .joint, accounts: [
            Account(name: "Starling Joint",  kind: "The pot",         value:   3410),
            Account(name: "Chase Saver",     kind: "Emergency fund",  value:  11200),
            Account(name: "14 Ashcombe Rd",  kind: "Property, est.",  value: 412000),
        ]),
        AccountGroup(name: "Sam", ledger: .sam, accounts: [
            Account(name: "Lloyds Current",   kind: "Current account", value:  1860),
            Account(name: "Trading 212 ISA",  kind: "Stocks & shares", value:  9750),
            Account(name: "Aviva Pension",    kind: "Workplace",       value: 27800),
        ]),
    ]

    static let liabilityGroup = AccountGroup(name: "Owed", ledger: nil, accounts: [
        Account(name: "Halifax Mortgage", kind: "2.1% to Mar 2028",  value: -286_400),
        Account(name: "Car loan · Sam",   kind: "4.9% APR",          value:   -6_180),
        Account(name: "Amex",             kind: "Cleared monthly",   value:   -1_240),
    ])

    // MARK: - Recaps

    static let recaps: [MonthRecap] = [
        MonthRecap(month: "Jun", year: 2026, total: 3321, budget: 3228, income: 5946, saved: 600,
                   categories: [
                       RecapCategory(name: "Rent & mortgage",  amount: 1420, delta:    0),
                       RecapCategory(name: "Home & repairs",   amount:  210, delta:   96),
                       RecapCategory(name: "Groceries",        amount:  452, delta:  -24),
                       RecapCategory(name: "Eating out",       amount:  168, delta:   12),
                       RecapCategory(name: "Energy & water",   amount:  205, delta:   15),
                       RecapCategory(name: "Transport",        amount:  128, delta:   -6),
                       RecapCategory(name: "Subscriptions",    amount:   42, delta:    0),
                       RecapCategory(name: "Savings transfer", amount:  600, delta:    0),
                       RecapCategory(name: "Other",            amount:   96, delta:   -8),
                   ],
                   takeaway: "Home & repairs ran hot in June — the boiler service and two filter changes landed in the same week."),

        MonthRecap(month: "Jul", year: 2026, total: 3189, budget: 3228, income: 5946, saved: 600,
                   categories: [
                       RecapCategory(name: "Rent & mortgage",  amount: 1420, delta:    0),
                       RecapCategory(name: "Groceries",        amount:  476, delta:   24),
                       RecapCategory(name: "Energy & water",   amount:  190, delta:  -15),
                       RecapCategory(name: "Eating out",       amount:  142, delta:  -26),
                       RecapCategory(name: "Transport",        amount:  140, delta:   12),
                       RecapCategory(name: "Home & repairs",   amount:   55, delta: -155),
                       RecapCategory(name: "Subscriptions",    amount:   47, delta:    5),
                       RecapCategory(name: "Savings transfer", amount:  600, delta:    0),
                       RecapCategory(name: "Other",            amount:  119, delta:   23),
                   ],
                   takeaway: "Your quietest month this year. The £39 under budget rolled into the joint pot rather than being spent."),

        MonthRecap(month: "Aug", year: 2026, total: 3286, budget: 3228, income: 5884, saved: 600,
                   categories: [
                       RecapCategory(name: "Rent & mortgage",  amount: 1420, delta:   0),
                       RecapCategory(name: "Groceries",        amount:  498, delta:  22),
                       RecapCategory(name: "Eating out",       amount:  214, delta:  72),
                       RecapCategory(name: "Energy & water",   amount:  176, delta: -14),
                       RecapCategory(name: "Transport",        amount:  132, delta:  -8),
                       RecapCategory(name: "Home & repairs",   amount:   96, delta:  41),
                       RecapCategory(name: "Subscriptions",    amount:   47, delta:   0),
                       RecapCategory(name: "Savings transfer", amount:  600, delta:   0),
                       RecapCategory(name: "Other",            amount:  103, delta: -16),
                   ],
                   takeaway: "Eating out is the only envelope with three consecutive overspends. Raising it to £180 and trimming Transport would balance the month without changing behaviour."),
    ]

    // MARK: - Payslips

    static let payslips: [Payslip] = [
        Payslip(ledger: .ana, name: "Ana", gross: 4250, tax: 612.40, nationalInsurance: 284.10,
                received: 3341.28, expected: 3341,
                note: "Expected net £3,341. Landed 10 Aug, 28p over — rounding on the pension relief."),
        Payslip(ledger: .sam, name: "Sam", gross: 3180, tax: 389.20, nationalInsurance: 186.40,
                received: 2543.10, expected: 2604.40,
                note: "Expected net £2,604.40. Tax code moved to 1185L mid-month — worth checking with payroll before September."),
    ]

    // MARK: - Bills

    static let bills: [Bill] = [
        Bill(day: 16, name: "Council tax",      meta: "Camden · direct debit", amount: 212, isEstimated: false),
        Bill(day: 18, name: "Broadband",        meta: "Community Fibre",       amount:  38, isEstimated: false),
        Bill(day: 22, name: "Energy",           meta: "Octopus · estimated",   amount: 142, isEstimated: true),
        Bill(day: 25, name: "Car loan",         meta: "Sam's personal",        amount: 186, isEstimated: false),
        Bill(day: 28, name: "Subscriptions",    meta: "7 renewals",            amount:  47, isEstimated: false),
        Bill(day: 30, name: "Savings transfer", meta: "To Chase Saver",        amount: 600, isEstimated: false),
    ]

    /// Bills still to leave the pot this month.
    static let committedRemaining: Double = 392
    static let daysInMonth = 30

    // MARK: - Alerts

    static let alerts: [AlertItem] = [
        AlertItem(kind: .envelope, when: "2h",
                  title: "Eating out is £23 over",
                  body: "Third month running. Tap to rebalance from Transport, which is 18% under.",
                  tone: .attention),
        AlertItem(kind: .payslip, when: "Yesterday",
                  title: "Sam's net pay was £61.30 short",
                  body: "Expected £2,604.40 after tax and NI. Tax code changed to 1185L.",
                  tone: .attention),
        AlertItem(kind: .jointPot, when: "Fri",
                  title: "Both contributions landed",
                  body: "£3,400 in. Rent cleared on the 1st, £392 of bills still to go.",
                  tone: .positive),
        AlertItem(kind: .goal, when: "Mon",
                  title: "Kitchen fund passed 40%",
                  body: "£7,400 of £18,000. On track for May 2028 at the current rate.",
                  tone: .positive, isHighlighted: true),
    ]

    // MARK: - Home summary

    static let augustRecapDelta: Double = 58
    static let unbudgetedInPot: Double = 172
}
