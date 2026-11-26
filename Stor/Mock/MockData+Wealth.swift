#if DEBUG
import Foundation

extension MockData {

    // MARK: - Net worth

    static var netWorth: NetWorth {
        NetWorth(current: 233_940, monthlyChange: 3180, series: [
            NetWorthRange.oneMonth.rawValue: points(days: 30, [232.4, 232.6, 233, 233.2, 233.5, 233.7, 233.94]),
            NetWorthRange.sixMonths.rawValue: points(days: 182, [228.1, 229.4, 230, 231.2, 232.4, 233.94]),
            NetWorthRange.oneYear.rawValue: points(days: 365, [219.4, 221, 222.3, 223.1, 224.8, 226,
                                                               227.2, 228.1, 229.4, 230, 231.2, 233.94]),
            NetWorthRange.all.rawValue: points(days: 2555, [148, 163, 177, 190, 201, 212, 222, 233.94]),
        ])
    }

    /// Spreads values given in thousands evenly across the last `days` days.
    private static func points(days: Int, _ thousands: [Double]) -> [NetWorthPoint] {
        thousands.enumerated().map { index, value in
            let back = days - days * index / max(1, thousands.count - 1)
            return NetWorthPoint(date: daysFromNow(-back), value: value * 1000)
        }
    }

    static let accountGroups: [AccountGroup] = [
        AccountGroup(name: "Ana", ledger: .you, accounts: [
            Account(name: "Monzo Current", kind: "Current account",  value:  2140),
            Account(name: "Vanguard ISA",  kind: "Stocks & shares",  value: 18400),
            Account(name: "Nest Pension",  kind: "Workplace",        value: 41200),
        ]),
        AccountGroup(name: "Joint", ledger: .joint, accounts: [
            Account(name: "Starling Joint",  kind: "The pot",         value:   3410),
            Account(name: "Chase Saver",     kind: "Emergency fund",  value:  11200),
            Account(name: "14 Ashcombe Rd",  kind: "Property, est.",  value: 412000),
        ]),
        AccountGroup(name: "Sam", ledger: .partner, accounts: [
            Account(name: "Lloyds Current",   kind: "Current account", value:  1860),
            Account(name: "Trading 212 ISA",  kind: "Stocks & shares", value:  9750),
            Account(name: "Aviva Pension",    kind: "Workplace",       value: 27800),
        ]),
        AccountGroup(name: "Owed", ledger: nil, accounts: [
            Account(name: "Halifax Mortgage", kind: "2.1% to Mar 2028",  value: -286_400),
            Account(name: "Car loan · Sam",   kind: "4.9% APR",          value:   -6_180),
            Account(name: "Amex",             kind: "Cleared monthly",   value:   -1_240),
        ]),
    ]

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
        Payslip(ledger: .you, name: "Ana", gross: 4250, tax: 612.40, nationalInsurance: 284.10,
                received: 3341.28, expected: 3341,
                note: "Expected net £3,341. Landed 28p over — rounding on the pension relief."),
        Payslip(ledger: .partner, name: "Sam", gross: 3180, tax: 389.20, nationalInsurance: 186.40,
                received: 2543.10, expected: 2604.40,
                note: "Expected net £2,604.40. Tax code moved to 1185L mid-month — worth checking with payroll."),
    ]

    // MARK: - Bills

    private static func bill(_ id: String, _ name: String, _ group: String, _ kind: Bill.Kind, _ category: Bill.Category,
                             _ amount: Double, in days: Int?, meta: String = "", estimated: Bool = false) -> Bill {
        Bill(id: id, name: name, group: group, kind: kind, category: category, amount: amount, frequency: .monthly,
             months: [], paidFrom: .joint, dueDay: days.map { MonthCalendar.day(of: daysFromNow($0)) }, meta: meta,
             isEstimated: estimated, thisMonth: amount)
    }

    static var bills: [Bill] {
        [
            bill("rent", "Rent", "Home", .bill, .essential, 1850, in: 2, meta: "Standing order"),
            bill("council", "Council tax", "Home", .bill, .essential, 212, in: 4, meta: "Camden · direct debit"),
            bill("broadband", "Broadband", "Home", .bill, .essential, 38, in: 8, meta: "Community Fibre"),
            bill("energy", "Energy", "Home", .bill, .essential, 142, in: 11, meta: "Octopus", estimated: true),
            bill("food", "Groceries top-up", "Groceries", .pot, .essential, 520, in: nil),
            bill("subs", "Streaming", "Subscriptions", .bill, .discretionary, 47, in: 14),
            bill("holiday", "Holiday", "Holiday", .saving, .discretionary, 250, in: nil),
            bill("isa", "Stocks & shares", "Investing", .investment, .saving, 150, in: nil),
        ]
    }

    /// Ana and Sam's month, worked out as the server would for these bills.
    static var plan: BudgetPlan {
        BudgetPlan(
            month: BudgetPlan.key(for: Date()), hub: .you,
            settings: BudgetSettings(essentialPct: 50, discretionaryPct: 30, savingPct: 20, loanAllocation: 0, cashCap: 700),
            income: 5945, loanRepayments: 0, loanOverpay: 0, fixedInvesting: 150, addInvesting: 1386, billsAndPots: 3059,
            cashEach: 700, stays: 700, bills: bills,
            groups: [.init(name: "Home", amount: 2242), .init(name: "Investing", amount: 1536),
                     .init(name: "Cash accounts", amount: 1400), .init(name: "Groceries", amount: 520),
                     .init(name: "Savings pots", amount: 250), .init(name: "Subscriptions", amount: 47)],
            transfers: [
                .init(key: "pay:2", kind: .payIn, ledger: .partner, group: nil, amount: 2604, done: true),
                .init(key: "pot:Home", kind: .pot, ledger: nil, group: "Home", amount: 2242, done: true),
                .init(key: "pot:Groceries", kind: .pot, ledger: nil, group: "Groceries", amount: 520, done: false),
                .init(key: "pot:Subscriptions", kind: .pot, ledger: nil, group: "Subscriptions", amount: 47, done: false),
                .init(key: "pot:Holiday", kind: .pot, ledger: nil, group: "Holiday", amount: 250, done: false),
                .init(key: "investing:Investing", kind: .investing, ledger: nil, group: "Investing", amount: 1536, done: false),
                .init(key: "cash:2", kind: .cash, ledger: .partner, group: nil, amount: 700, done: false),
            ],
            split: [.init(category: .essential, allocated: 2972.5, actual: 2972.5, using: 2762, status: .left),
                    .init(category: .discretionary, allocated: 1783.5, actual: 1783.5, using: 297, status: .spare),
                    .init(category: .saving, allocated: 1189, actual: 2675.5, using: 150, status: .spare)],
            biggest: bills.filter { $0.kind != .saving && $0.kind != .investment }
                .sorted { $0.amount > $1.amount }.map { .init(id: $0.id, name: $0.name, group: $0.group, amount: $0.amount) },
            cashAccounts: [.init(ledger: .you, allowance: 700, personalBills: 0, left: 700),
                           .init(ledger: .partner, allowance: 700, personalBills: 45, left: 655)],
            forecast: (0..<12).map { offset in
                let month = MonthCalendar(date: Date()).adding(months: offset)
                return .init(month: BudgetPlan.key(for: month), bills: 2289, potsAndSavings: 770, addInvesting: 1386,
                             cashEach: 700, extraBills: [], isShort: false)
            })
    }

    // MARK: - Alerts

    static var alerts: [AlertItem] {
        [
            AlertItem(kind: .envelope, date: Date().addingTimeInterval(-7200),
                      title: "Eating out is £23 over",
                      body: "Third month running. Tap to rebalance from Transport, which is 18% under.",
                      tone: .attention),
            AlertItem(kind: .payslip, date: daysFromNow(-1),
                      title: "Sam's net pay was £61.30 short",
                      body: "Expected £2,604.40 after tax and NI. Tax code changed to 1185L.",
                      tone: .attention),
            AlertItem(kind: .jointPot, date: daysFromNow(-3),
                      title: "Both contributions landed",
                      body: "£3,400 in. Rent cleared on the 1st, £392 of bills still to go.",
                      tone: .positive),
            AlertItem(kind: .goal, date: daysFromNow(-6),
                      title: "Kitchen fund passed 40%",
                      body: "£7,400 of £18,000. On track for May 2028 at the current rate.",
                      tone: .positive, isHighlighted: true),
        ]
    }
}

extension AppState {
    /// A populated household for SwiftUI previews.
    static var preview: AppState { AppState(snapshot: MockData.snapshot, plan: MockData.plan) }
}
#endif
