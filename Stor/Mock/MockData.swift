import Foundation

enum MockData {

    // MARK: Members
    static let sarah = Member(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Ross Curlaughlin",
        email: "rc07jnr@gmail.com",
        age: 27,
        gender: "Male",
        isCreator: true
    )

    static let james = Member(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Niámh Curlaughlin",
        email: "nmclaughlin1504@gmail.com",
        age: 27,
        gender: "Female",
        isCreator: false
    )

    // MARK: Household
    static let household = Household(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        name: "The Murphys",
        members: [sarah, james],
        memberSince: iso("2023-03-15"),
        framework: .fiftyThirtyTwenty,
        requiresApprovals: true,
        surplusSplitMethod: .proportional,
        inviteCode: "MURP-4821"
    )

    // MARK: Incomes
    static let incomes: [Income] = [
        Income(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            memberID: sarah.id,
            memberName: sarah.name,
            grossMonthly: 4_500,
            netMonthly: 3_200
        ),
        Income(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
            memberID: james.id,
            memberName: james.name,
            grossMonthly: 3_600,
            netMonthly: 2_450
        ),
    ]

    static var householdNetMonthly: Double { incomes.reduce(0) { $0 + $1.netMonthly } }

    // MARK: Personal details & tax (Sarah – logged-in user)
    static let sarahPersonalDetails = PersonalDetails(
        name: sarah.name,
        email: sarah.email,
        age: sarah.age,
        gender: sarah.gender,
        currency: "GBP"
    )

    static let sarahTaxInfo = TaxInfo(
        grossMonthly: 4_500,
        taxCode: "1257L",
        taxSystem: "PAYE",
        taxYear: "2025/26",
        maritalStatus: "Married",
        pensionContributionPercent: 5,
        hasStudentLoan: false,
        studentLoanPlan: nil
    )

    static let jamesTaxInfo = TaxInfo(
        grossMonthly: 3_600,
        taxCode: "1257L",
        taxSystem: "PAYE",
        taxYear: "2025/26",
        maritalStatus: "Married",
        pensionContributionPercent: 5,
        hasStudentLoan: true,
        studentLoanPlan: "Plan 2"
    )

    // MARK: Expenses
    // Monthly totals: Needs ≈ £3,475 (123% of the £2,825 budget — over)  Wants ≈ £945  Sinking ≈ £600
    static let expenses: [Expense] = [
        // Bills – Needs
        expense("Rent",          2_228,   .monthly, .bills,       by: sarah, approved: true),
        expense("Electricity",      85,   .monthly, .bills,       by: sarah, approved: true),
        expense("Gas",              65,   .monthly, .bills,       by: sarah, approved: true),
        expense("Water",            35,   .monthly, .bills,       by: james, approved: true),
        expense("Council Tax",     162,   .monthly, .bills,       by: james, approved: true),
        expense("Home Insurance",  336,   .annual,  .bills,       by: sarah, approved: true),
        expense("Car Insurance",   648,   .annual,  .bills,       by: james, approved: true),
        expense("Broadband",        38,   .monthly, .bills,       by: sarah, approved: true),
        // Groceries – Needs
        expense("Weekly Shop",     120,   .weekly,  .groceries,   by: sarah, approved: true),
        // Transport – Needs
        expense("Train Pass",      195,   .monthly, .transport,   by: sarah, approved: true),
        expense("Petrol",           65,   .monthly, .transport,   by: james, approved: true),
        // Subscriptions – Wants
        expense("Netflix",          18,   .monthly, .subscriptions, by: sarah, approved: true),
        expense("Spotify",          11,   .monthly, .subscriptions, by: sarah, approved: true),
        expense("iCloud+",           3,   .monthly, .subscriptions, by: sarah, approved: true),
        expense("Amazon Prime",      95,   .annual,  .subscriptions, by: james, approved: true),
        expense("Sarah's Gym",      45,   .monthly, .subscriptions, by: sarah, approved: true),
        expense("James's Gym",      35,   .monthly, .subscriptions, by: james, approved: true),
        // Eating Out – Wants
        expense("Dining Out",      280,   .monthly, .eatingOut,   by: james, approved: true),
        expense("Takeaways",        60,   .monthly, .eatingOut,   by: james, approved: true),
        // Entertainment – Wants
        expense("Nights Out",      150,   .monthly, .entertainment, by: sarah, approved: true),
        // Clothing – Wants
        expense("Personal Shopping", 120, .monthly, .clothing,    by: sarah, approved: true),
        expense("Haircuts",          40,  .monthly, .clothing,    by: james, approved: true),
        // Sinking Funds – Savings
        expense("Emergency Fund",  200,   .monthly, .sinkingFunds, by: sarah, approved: true),
        expense("Holiday Fund",    300,   .monthly, .sinkingFunds, by: sarah, approved: true),
        expense("Home Renovation", 200,   .monthly, .sinkingFunds, by: james, approved: true),
        expense("Car Fund",        100,   .monthly, .sinkingFunds, by: james, approved: true),
        // Pending approval (James wants to add a cinema subscription)
        expense("Cinema Club",      15,   .monthly, .subscriptions, by: james, approved: false),
    ]

    /// Previous month's total approved expenses, used to show a month-on-month
    /// comparison on the dashboard. (Current approved total is roughly £4,270.)
    static let previousMonthExpenses: Double = 4_410

    // MARK: Savings pots
    static let savingsPots: [SavingsPot] = [
        SavingsPot(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000301")!,
            name: "Emergency Fund",
            current: 2_400,
            target: 3_600,
            monthlyContribution: 200,
            emoji: "🛡️"
        ),
        SavingsPot(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000302")!,
            name: "Ibiza 2026",
            current: 1_850,
            target: 3_500,
            monthlyContribution: 300,
            emoji: "✈️"
        ),
        SavingsPot(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000303")!,
            name: "Home Renovation",
            current: 4_200,
            target: 10_000,
            monthlyContribution: 200,
            emoji: "🏡"
        ),
        SavingsPot(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000304")!,
            name: "Car Fund",
            current: 650,
            target: 2_000,
            monthlyContribution: 100,
            emoji: "🚗"
        ),
    ]

    // MARK: Pensions
    static let pensions: [Pension] = [
        Pension(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000401")!,
            memberID: sarah.id,
            memberName: sarah.name,
            currentValue: 28_500,
            target: 200_000,
            lastUpdated: iso("2026-06-01")
        ),
        Pension(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000402")!,
            memberID: james.id,
            memberName: james.name,
            currentValue: 41_200,
            target: 250_000,
            lastUpdated: iso("2026-05-28")
        ),
    ]

    // MARK: ISAs
    static let isas: [ISA] = [
        ISA(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000501")!,
            memberID: sarah.id,
            memberName: sarah.name,
            type: "Stocks & Shares ISA",
            balance: 8_450,
            contributionsThisYear: 4_000,
            annualAllowance: 20_000
        ),
        ISA(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000502")!,
            memberID: james.id,
            memberName: james.name,
            type: "Stocks & Shares ISA",
            balance: 12_200,
            contributionsThisYear: 6_500,
            annualAllowance: 20_000
        ),
    ]

    // MARK: Financial position
    // Income £5,650 · Expenses £3,598 · Savings £600 · Surplus £1,452
    static let financialPosition = FinancialPosition(
        monthlyIncome:   5_650,
        monthlyExpenses: 3_598,
        monthlySavings:    600
    )

    // MARK: Helpers
    private static func iso(_ string: String) -> Date {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: string) ?? Date()
    }

    private static func expense(
        _ name: String,
        _ total: Double,
        _ freq: ExpenseFrequency,
        _ cat: ExpenseCategory,
        by member: Member,
        approved: Bool
    ) -> Expense {
        Expense(
            id: UUID(),
            name: name,
            total: total,
            frequency: freq,
            category: cat,
            addedBy: member.id,
            approvalStatus: approved
                ? .approved
                : .pendingApproval(agreedBy: [])
        )
    }
}
