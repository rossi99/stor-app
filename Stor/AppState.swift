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

    /// Nothing has happened on this ledger yet, so there is no calculation to show.
    var isEmpty: Bool { pot == 0 && spent == 0 && committed == 0 }

    var fraction: Double {
        guard pot > 0 else { return 0 }
        return min(1, spent / pot)
    }
}

@MainActor
@Observable
final class AppState {

    enum LoadState { case loading, loaded, failed }

    private let backend: any StorBackend
    private let clock: () -> Date

    init(backend: any StorBackend = LocalBackend(), snapshot: HouseholdSnapshot = .empty,
         clock: @escaping () -> Date = Date.init) {
        self.backend = backend
        self.snapshot = snapshot
        self.clock = clock
    }

    // MARK: - Data

    var snapshot: HouseholdSnapshot
    var loadState: LoadState = .loaded
    /// A write the server refused, already rolled back, waiting to be shown.
    var syncError: String?

    var month: MonthCalendar { MonthCalendar(date: clock()) }

    func loadHousehold() async {
        loadState = .loading
        do {
            snapshot = try await backend.loadHousehold()
            addedTransactions = []
            loadState = .loaded
        } catch {
            loadState = .failed
        }
    }

    /// Runs a write after the local change; a failure undoes it and tells the user.
    private func sync(failure: String, undo: @escaping () -> Void,
                      _ call: @escaping (any StorBackend) async throws -> Void) {
        let backend = backend
        Task {
            do {
                try await call(backend)
            } catch {
                undo()
                syncError = failure
            }
        }
    }

    // MARK: - Session

    var isAuthenticated = false
    var isAuthenticating = false
    /// Checking a stored session at launch, before showing the sign-in gate.
    var isRestoring = false
    var authError: String?
    var userEmail = ""
    var hasCompletedSetup = false
    var onboardingStep = 0
    var moneyModel: MoneyModel = .ledgers

    var linkedAccounts: Set<String> {
        get { snapshot.linkedAccountIDs }
        set { snapshot.linkedAccountIDs = newValue }
    }

    // MARK: - Preferences

    var currency: Currency = .gbp
    var privacyMode = false
    var showPayslipCheck = true

    var topUpDay: Int {
        get { snapshot.topUpDay }
        set {
            let previous = snapshot.topUpDay
            snapshot.topUpDay = newValue
            sync(failure: "Your top-up day couldn’t be saved.", undo: { [weak self] in
                self?.snapshot.topUpDay = previous
            }) { try await $0.setTopUpDay(newValue) }
        }
    }

    var money: MoneyFormatter {
        MoneyFormatter(currency: currency, privacyMode: privacyMode)
    }

    // MARK: - Navigation

    var selectedTab: AppTab = .home
    var homePath: [Route] = []
    var wealthPath: [Route] = []

    // MARK: - Household

    var members: [HouseholdMember] {
        get { snapshot.members }
        set { snapshot.members = newValue }
    }

    /// Ledgers in display order: you, the joint pot, then everyone else.
    var ledgers: [Ledger] {
        [.you, .joint] + members.map(\.ledger).filter { $0 != .you }
    }

    /// "Two personal accounts + one joint pot".
    var householdSummary: String {
        let count = ["One", "Two", "Three", "Four"][max(0, min(3, members.count - 1))]
        return "\(count) personal account\(members.count == 1 ? "" : "s") + one joint pot"
    }

    /// People in the household, 1 to 4. The server refuses to remove anyone with spending recorded.
    var householdSize: Int {
        get { members.count }
        set {
            guard Ledger.people.indices.contains(newValue - 1), newValue != members.count else { return }
            let previous = members
            members = Ledger.people.prefix(newValue).map { ledger in
                previous.first { $0.ledger == ledger } ?? .placeholder(ledger)
            }
            if !ledgers.contains(ledger) { ledger = .joint }
            if let feedFilter, !ledgers.contains(feedFilter) { self.feedFilter = nil }
            sync(failure: "Your household size couldn’t be changed. Anyone with spending recorded can’t be removed.", undo: { [weak self] in
                self?.members = previous
            }) { try await $0.setHouseholdSize(newValue) }
        }
    }

    var you: HouseholdMember { member(.you) }
    var partner: HouseholdMember { member(.partner) }

    func member(_ ledger: Ledger) -> HouseholdMember {
        members.first { $0.ledger == ledger } ?? .placeholder(ledger)
    }

    func name(for ledger: Ledger) -> String {
        ledger == .joint ? "Joint" : member(ledger).firstName
    }

    /// Total standing orders into the pot each month.
    var potContribution: Double {
        members.reduce(0) { $0 + $1.contribution }
    }

    @discardableResult
    func saveContributions(_ draft: ContributionDraft) -> Bool {
        guard let values = draft.values,
              Set(values.keys) == Set(members.map(\.ledger)) else { return false }
        let previous = members
        for index in members.indices {
            members[index].contribution = values[members[index].ledger]!
        }
        sync(failure: "Your contributions couldn’t be saved.", undo: { [weak self] in
            self?.members = previous
        }) { try await $0.saveContributions(values) }
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

    private var summary: LedgerSummary? {
        snapshot.ledgers.first { $0.ledger == ledger }
    }

    // MARK: - Envelopes

    var envelopes: [Envelope] {
        let additions = addedTransactions.filter { $0.ledger == ledger && $0.amount < 0 }
        var result = (summary?.envelopes ?? []).map { envelope in
            let extra = additions.filter { $0.category == envelope.name }
                .reduce(0) { $0 - $1.amount }
            guard extra > 0 else { return envelope }
            let spent = envelope.spent + extra
            return Envelope(name: envelope.name, spent: spent, budget: envelope.budget,
                            detail: "Includes newly added spending",
                            pace: spent > envelope.budget ? "Over budget" : "Within budget",
                            threeMonthAverage: envelope.threeMonthAverage)
        }
        let names = Set(result.map(\.name))
        for category in Set(additions.map(\.category)).subtracting(names).sorted() {
            result.append(Envelope(name: category,
                                   spent: additions.filter { $0.category == category }.reduce(0) { $0 - $1.amount },
                                   budget: 0, detail: "No budget set", pace: "Unbudgeted"))
        }
        return result
    }

    /// Spend categories the selected ledger has no budget for yet.
    var unbudgetedCategories: [String] {
        let budgeted = Set(summary?.envelopes.map(\.name) ?? [])
        return SpendDraft.categories.filter { !budgeted.contains($0) }
    }

    @discardableResult
    func createEnvelope(_ draft: EnvelopeDraft) -> Bool {
        guard let budget = draft.amount, unbudgetedCategories.contains(draft.category) else { return false }
        let ledger = ledger
        let envelope = Envelope(name: draft.category, spent: 0, budget: budget,
                                detail: "No spending yet", pace: "Within budget")
        let previous = snapshot.ledgers
        if let i = snapshot.ledgers.firstIndex(where: { $0.ledger == ledger }) {
            snapshot.ledgers[i].envelopes.append(envelope)
        } else {
            snapshot.ledgers.append(LedgerSummary(ledger: ledger, available: 0, spent: 0, committed: 0,
                                                  unbudgeted: 0, envelopes: [envelope]))
        }
        sync(failure: "Your \(envelope.name) budget couldn’t be saved.", undo: { [weak self] in
            self?.snapshot.ledgers = previous
        }) { try await $0.setEnvelopeBudget(ledger: ledger, name: envelope.name, budget: budget) }
        return true
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
    var unbudgetedTotal: Double { summary?.unbudgeted ?? 0 }

    /// Under £100 left is close enough to the edge to warrant the warning tint.
    var isBudgetTight: Bool { leftTotal < 100 }

    // MARK: - Safe to spend

    var safeToSpend: SafeToSpend {
        let available = summary?.available ?? 0
        let committed = summary?.committed ?? 0
        let pot = ledger == .joint ? potContribution + available : available
        let spent = (summary?.spent ?? 0) + newSpending
        let isEmpty = pot == 0 && spent == 0 && committed == 0

        let caption: String
        switch (ledger, isEmpty) {
        case (.joint, true):
            caption = "Nothing in the pot yet. Set your monthly contributions to get started."
        case (.joint, false):
            caption = committed > 0
                ? "after the \(money(committed)) still to leave the pot this month"
                : "with nothing else due to leave the pot this month"
        case (_, true):
            caption = "Nothing tracked here yet. Spending you add to this ledger will show here."
        case (_, false):
            caption = privacySentence.map { "Personal allowance. \($0) the total, not the merchants." }
                ?? "Personal allowance."
        }

        return SafeToSpend(
            pot: pot, spent: spent, committed: committed,
            label: ledger == .joint ? "Safe to spend · joint" : "Safe to spend · \(name(for: ledger))",
            caption: caption
        )
    }

    /// Who else sees this personal ledger's total; nil when nobody does.
    private var privacySentence: String? {
        guard ledger == .you else { return you.name.isEmpty ? "You see" : "\(you.firstName) sees" }
        let others = members.filter { $0.ledger != .you }
        switch others.count {
        case 0: return nil
        case 1: return "\(others[0].firstName) sees"
        default: return "Everyone else sees"
        }
    }

    // MARK: - Transactions

    /// Spends added since the last load sit in front of the server's list.
    var addedTransactions: [Transaction] = []
    var feedFilter: Ledger?

    var allTransactions: [Transaction] {
        addedTransactions + snapshot.transactions
    }

    var filteredTransactions: [Transaction] {
        guard let feedFilter else { return allTransactions }
        return allTransactions.filter { $0.ledger == feedFilter }
    }

    /// Day headings in encounter order, each with its rows.
    var transactionGroups: [(label: String, rows: [Transaction])] {
        var order: [String] = []
        var rows: [String: [Transaction]] = [:]
        for tx in filteredTransactions {
            let label = dayLabel(tx.date)
            if rows[label] == nil { order.append(label) }
            rows[label, default: []].append(tx)
        }
        return order.map { ($0, rows[$0] ?? []) }
    }

    private func dayLabel(_ date: Date) -> String {
        let label = MonthCalendar.format(date, "EEE d MMM")
        return month.isToday(date) ? "Today · \(label)" : label
    }

    // MARK: - Goals

    var goals: [Goal] { snapshot.goals }

    func adjustGoal(_ id: String, by delta: Double) {
        guard let i = snapshot.goals.firstIndex(where: { $0.id == id }) else { return }
        let previous = snapshot.goals[i].monthly
        let monthly = max(Goal.minimumMonthly, previous + delta)
        snapshot.goals[i].monthly = monthly
        sync(failure: "That goal change couldn’t be saved.", undo: { [weak self] in
            guard let self, let i = self.snapshot.goals.firstIndex(where: { $0.id == id }) else { return }
            self.snapshot.goals[i].monthly = previous
        }) { try await $0.setGoalMonthly(id: id, monthly: monthly) }
    }

    @discardableResult
    func createGoal(_ draft: GoalDraft) -> Bool {
        guard let goal = draft.goal() else { return false }
        snapshot.goals.append(goal)
        sync(failure: "Your \(goal.name) goal couldn’t be saved.", undo: { [weak self] in
            self?.snapshot.goals.removeAll { $0.id == goal.id }
        }) { try await $0.createGoal(goal) }
        return true
    }

    // MARK: - Bills

    /// Soonest first, excluding anything already paid.
    var upcomingBills: [Bill] {
        let today = month.startOfToday()
        return snapshot.bills.filter { $0.dueDate >= today }.sorted { $0.dueDate < $1.dueDate }
    }

    @discardableResult
    func createBill(_ draft: BillDraft) -> Bool {
        guard let bill = draft.bill() else { return false }
        snapshot.bills.append(bill)
        snapshot.bills.sort { $0.dueDate < $1.dueDate }
        sync(failure: "Your \(bill.name) bill couldn’t be saved.", undo: { [weak self] in
            self?.snapshot.bills.removeAll { $0.id == bill.id }
        }) { try await $0.createBill(bill) }
        return true
    }

    // MARK: - Wealth

    var netWorthRange: NetWorthRange = .oneYear
    var showLiabilities = true

    var accountGroups: [AccountGroup] {
        snapshot.accountGroups.filter { showLiabilities || $0.ledger != nil }
    }

    var hasLiabilities: Bool { snapshot.accountGroups.contains { $0.ledger == nil } }

    var netWorthPoints: [NetWorthPoint] {
        snapshot.netWorth?.series[netWorthRange.rawValue] ?? []
    }

    /// Change across the selected window, in pounds.
    var netWorthRangeGain: Double {
        guard let first = netWorthPoints.first, let last = netWorthPoints.last else { return 0 }
        return (last.value - first.value).rounded()
    }

    // MARK: - Recap

    var selectedRecapID: String?

    /// The chosen month, falling back to the latest finished one.
    var recap: MonthRecap? {
        snapshot.recaps.first { $0.id == selectedRecapID } ?? snapshot.recaps.last
    }

    // MARK: - Add spend

    var isAddingSpend = false
    var draft = SpendDraft()

    func openAddSpend(for source: Ledger? = nil) {
        draft = SpendDraft()
        draft.ledger = source ?? ledger
        draft.splitsWithPartner = members.count == 2
        isAddingSpend = true
    }

    func cancelAddSpend() {
        isAddingSpend = false
        draft = SpendDraft()
    }

    /// Commits the draft and drops the user into the ledger to see it land.
    func commitSpend() {
        guard draft.isValid else { return }
        let spend = draft.asTransaction(date: clock()) { self.name(for: $0) }
        let amount = money(draft.amount, decimals: 2)
        addedTransactions.insert(spend, at: 0)
        isAddingSpend = false
        draft = SpendDraft()
        feedFilter = nil
        selectedTab = .ledger
        sync(failure: "Your \(amount) spend couldn’t be saved, so it was removed. Please add it again.", undo: { [weak self] in
            self?.addedTransactions.removeAll { $0.id == spend.id }
        }) { try await $0.addSpend(spend) }
    }

    // MARK: - Auth

    /// An existing account has already been through setup, so signing in lands
    /// straight in the app rather than replaying the steps.
    func signIn(email: String, password: String) async {
        await authenticate { try await $0.signIn(email: email, password: password) }
    }

    func signUp(email: String, password: String) async {
        await authenticate { try await $0.signUp(email: email, password: password) }
    }

    private func authenticate(_ call: (any StorBackend) async throws -> AuthSession) async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil
        defer { isAuthenticating = false }
        do {
            await begin(try await call(backend))
        } catch {
            authError = (error as? BackendError)?.message
                ?? "Couldn’t reach Stór. Check your connection and try again."
        }
    }

    /// Picks up a session saved on an earlier launch. Any failure leaves the sign-in gate showing.
    func restoreSession() async {
        isRestoring = true
        defer { isRestoring = false }
        if let session = try? await backend.restoreSession() {
            await begin(session)
        }
    }

    private func begin(_ session: AuthSession) async {
        userEmail = session.email
        hasCompletedSetup = session.hasCompletedSetup
        onboardingStep = 0
        loadState = .loading
        isAuthenticated = true
        await loadHousehold()
    }

    /// Clears everything the account loaded; the server revoke is best-effort.
    func signOut() {
        let backend = backend
        Task { try? await backend.signOut() }
        isAuthenticated = false
        userEmail = ""
        hasCompletedSetup = false
        onboardingStep = 0
        snapshot = .empty
        addedTransactions = []
        syncError = nil
        authError = nil
        selectedTab = .home
        homePath = []
        wealthPath = []
        ledger = .joint
        feedFilter = nil
        selectedRecapID = nil
        cancelAddSpend()
    }

    // MARK: - Setup flow

    func advanceOnboarding() {
        if onboardingStep < 2 {
            onboardingStep += 1
        } else {
            finishSetup()
        }
    }

    func retreatOnboarding() {
        if onboardingStep > 0 {
            onboardingStep -= 1
        } else {
            finishSetup()
        }
    }

    private func finishSetup() {
        hasCompletedSetup = true
        // Not rolled back: being returned to setup mid-session would be worse than replaying it next sign-in.
        sync(failure: "Your setup couldn’t be saved, so you may see it again next time.", undo: {}) {
            try await $0.completeSetup()
        }
    }

    func replaySetup() {
        onboardingStep = 0
        hasCompletedSetup = false
    }

    func toggleLink(_ id: String) {
        let previous = linkedAccounts
        if linkedAccounts.contains(id) {
            linkedAccounts.remove(id)
        } else {
            linkedAccounts.insert(id)
        }
        let linked = linkedAccounts
        sync(failure: "Your linked accounts couldn’t be saved.", undo: { [weak self] in
            self?.linkedAccounts = previous
        }) { try await $0.setLinkedAccounts(linked) }
    }
}
