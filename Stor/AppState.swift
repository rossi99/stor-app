import SwiftUI

/// Safe-to-spend for one ledger. Home leads with this rather than a balance:
/// a balance flatters you, this doesn't.
struct SafeToSpend {
    let pot: Double
    let spent: Double
    /// Bills still to leave the pot this month.
    let committed: Double
    let label: String
    let caption: String

    var remaining: Double { pot - spent - committed }

    var fraction: Double {
        guard pot > 0 else { return 0 }
        return min(1, spent / pot)
    }
}

@MainActor
@Observable
final class AppState {

    // MARK: - Session

    var isAuthenticated = false
    var userEmail = ""
    var hasCompletedSetup = false
    var onboardingStep = 0
    var moneyModel: MoneyModel = .ledgers
    var linkedAccounts: Set<String> = MockData.defaultLinkedAccounts

    // MARK: - Preferences

    var currency: Currency = .gbp
    var privacyMode = false
    var showPayslipCheck = true
    var topUpDay = 10

    var money: MoneyFormatter {
        MoneyFormatter(currency: currency, privacyMode: privacyMode)
    }

    // MARK: - Navigation

    var selectedTab: AppTab = .home
    var homePath: [Route] = []
    var wealthPath: [Route] = []

    // MARK: - Household

    var members: [HouseholdMember] = MockData.members

    var ana: HouseholdMember { member(.ana) }
    var sam: HouseholdMember { member(.sam) }

    func member(_ ledger: Ledger) -> HouseholdMember {
        members.first { $0.ledger == ledger } ?? MockData.members[0]
    }

    func name(for ledger: Ledger) -> String {
        ledger == .joint ? "Joint" : member(ledger).firstName
    }

    /// Total standing orders into the pot each month.
    var potContribution: Double {
        members.reduce(0) { $0 + $1.contribution }
    }

    /// A pot that can't cover average shared outgoings runs dry mid-month.
    var potFallsShort: Bool {
        potContribution < MockData.averageSharedOutgoings
    }

    @discardableResult
    func saveContributions(_ draft: ContributionDraft) -> Bool {
        guard let values = draft.values,
              Set(values.keys) == Set(members.map(\.ledger)) else { return false }
        for index in members.indices {
            members[index].contribution = values[members[index].ledger]!
        }
        return true
    }

    // MARK: - Ledger selection

    var ledger: Ledger = .joint {
        didSet { expandedCategory = nil }
    }

    /// The envelope or recap row currently expanded, if any.
    var expandedCategory: String?

    func toggleExpanded(_ name: String) {
        expandedCategory = expandedCategory == name ? nil : name
    }

    // MARK: - Envelopes

    var envelopes: [Envelope] {
        let additions = addedTransactions.filter { $0.ledger == ledger && $0.amount < 0 }
        var result = MockData.envelopes(for: ledger).map { envelope in
            let extra = additions.filter { $0.category == envelope.name }
                .reduce(0) { $0 - $1.amount }
            guard extra > 0 else { return envelope }
            let spent = envelope.spent + extra
            return Envelope(name: envelope.name, spent: spent, budget: envelope.budget,
                            detail: "Includes newly added spending",
                            pace: spent > envelope.budget ? "Over budget" : "Within budget")
        }
        let names = Set(result.map(\.name))
        for category in Set(additions.map(\.category)).subtracting(names).sorted() {
            result.append(Envelope(name: category,
                                   spent: additions.filter { $0.category == category }.reduce(0) { $0 - $1.amount },
                                   budget: 0, detail: "No budget set", pace: "Unbudgeted"))
        }
        return result
    }

    var priorityEnvelopes: [Envelope] {
        envelopes.sorted {
            if $0.isOver != $1.isOver { return $0.isOver }
            if $0.isOver { return $0.overspend > $1.overspend }
            return $0.fraction > $1.fraction
        }
    }

    var homeEnvelopes: [Envelope] {
        let over = priorityEnvelopes.filter(\.isOver)
        return Array((over.isEmpty ? priorityEnvelopes : over).prefix(3))
    }

    private var newSpending: Double {
        addedTransactions.filter { $0.ledger == ledger && $0.amount < 0 }.reduce(0) { $0 - $1.amount }
    }

    var budgetedTotal: Double { envelopes.reduce(0) { $0 + $1.budget } }
    var spentTotal: Double { envelopes.reduce(0) { $0 + $1.spent } }
    var leftTotal: Double { budgetedTotal - spentTotal }

    /// Under £100 left is close enough to the edge to warrant the warning tint.
    var isBudgetTight: Bool { leftTotal < 100 }

    // MARK: - Safe to spend

    var safeToSpend: SafeToSpend {
        switch ledger {
        case .joint:
            SafeToSpend(
                pot: potContribution + 180,
                spent: 2964 + newSpending,
                committed: MockData.committedRemaining,
                label: "Safe to spend · joint",
                caption: "after the \(money(MockData.committedRemaining)) still to leave the pot this month"
            )
        case .ana:
            SafeToSpend(
                pot: 700, spent: 383 + newSpending, committed: 0,
                label: "Safe to spend · Ana",
                caption: "Personal allowance. Sam sees the total, not the merchants."
            )
        case .sam:
            SafeToSpend(
                pot: 700, spent: 512 + newSpending, committed: 0,
                label: "Safe to spend · Sam",
                caption: "Personal allowance. Ana sees the total, not the merchants."
            )
        }
    }

    // MARK: - Transactions

    /// Spends added this session sit in front of the fixtures.
    var addedTransactions: [Transaction] = []
    var feedFilter: Ledger?

    var allTransactions: [Transaction] {
        addedTransactions + MockData.transactions
    }

    var filteredTransactions: [Transaction] {
        guard let feedFilter else { return allTransactions }
        return allTransactions.filter { $0.ledger == feedFilter }
    }

    /// Day headings in encounter order, each with its rows.
    var transactionGroups: [(label: String, rows: [Transaction])] {
        var order: [String] = []
        for tx in filteredTransactions where !order.contains(tx.group) {
            order.append(tx.group)
        }
        return order.map { label in
            (label, filteredTransactions.filter { $0.group == label })
        }
    }

    // MARK: - Goals

    var goals: [Goal] = MockData.goals

    func adjustGoal(_ id: String, by delta: Double) {
        guard let i = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[i].monthly = max(Goal.minimumMonthly, goals[i].monthly + delta)
    }

    // MARK: - Wealth

    var netWorthRange: NetWorthRange = .oneYear
    var showLiabilities = true

    var accountGroups: [AccountGroup] {
        showLiabilities ? MockData.assetGroups + [MockData.liabilityGroup] : MockData.assetGroups
    }

    /// Change across the selected window, in pounds.
    var netWorthRangeGain: Double {
        let series = MockData.netWorthSeries(netWorthRange)
        guard let first = series.first, let last = series.last else { return 0 }
        return ((last - first) * 1000).rounded()
    }

    // MARK: - Recap

    var recapMonth: String = "Aug"

    var recap: MonthRecap {
        MockData.recaps.first { $0.month == recapMonth } ?? MockData.recaps[2]
    }

    // MARK: - Add spend

    var isAddingSpend = false
    var draft = SpendDraft()

    func openAddSpend(for source: Ledger? = nil) {
        draft = SpendDraft()
        draft.ledger = source ?? ledger
        isAddingSpend = true
    }

    func cancelAddSpend() {
        isAddingSpend = false
        draft = SpendDraft()
    }

    /// Commits the draft and drops the user into the ledger to see it land.
    func commitSpend() {
        guard draft.isValid else { return }
        addedTransactions.insert(draft.asTransaction(), at: 0)
        isAddingSpend = false
        draft = SpendDraft()
        feedFilter = nil
        selectedTab = .ledger
    }

    // MARK: - Auth

    var knownAccounts: Set<String> = MockData.knownAccounts

    /// An existing account has already been through setup, so signing in lands
    /// straight in the app rather than replaying the steps.
    func signIn(email: String) {
        userEmail = email
        isAuthenticated = true
        hasCompletedSetup = true
    }

    func signUp(email: String) {
        userEmail = email
        isAuthenticated = true
        hasCompletedSetup = false
        onboardingStep = 0
    }

    /// Apple and Google return an identity, not a "first time" flag, so the
    /// branch is an account lookup: known signs in, unknown creates and onboards.
    func continueWith(email: String) {
        if knownAccounts.contains(email) {
            signIn(email: email)
        } else {
            knownAccounts.insert(email)
            signUp(email: email)
        }
    }

    // MARK: - Setup flow

    func advanceOnboarding() {
        if onboardingStep < 2 {
            onboardingStep += 1
        } else {
            hasCompletedSetup = true
        }
    }

    func retreatOnboarding() {
        if onboardingStep > 0 {
            onboardingStep -= 1
        } else {
            hasCompletedSetup = true
        }
    }

    func replaySetup() {
        onboardingStep = 0
        hasCompletedSetup = false
    }

    func toggleLink(_ id: String) {
        if linkedAccounts.contains(id) {
            linkedAccounts.remove(id)
        } else {
            linkedAccounts.insert(id)
        }
    }
}
