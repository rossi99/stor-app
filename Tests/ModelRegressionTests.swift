import Foundation

@main
struct ModelRegressionTests {
    @MainActor static func main() async {
        var checks = 0
        func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
            precondition(condition(), message)
            checks += 1
        }
        func close(_ left: Double, _ right: Double) -> Bool { abs(left - right) < 0.000_001 }

        var draft = SpendDraft()
        for key in [SpendDraft.Key.digit("1"), .digit("2"), .decimalPoint, .digit("3"), .digit("4")] {
            draft.apply(key)
        }
        expect(draft.entry == "12.34", "Keypad must enter pounds and pennies")
        draft.apply(.digit("5"))
        expect(draft.entry == "12.34", "A third decimal place must be rejected")
        draft.apply(.decimalPoint)
        expect(draft.entry == "12.34", "A second separator must be rejected")
        draft.apply(.delete)
        expect(draft.entry == "12.3", "Delete removes the last character")
        for invalid in ["", "0", "-1", "1.234", "1.2.3", "abc", "nan", "inf", "1000000", "1e4"] {
            draft.entry = invalid
            expect(!draft.isValid, "Reject invalid entry: \(invalid)")
        }
        for (input, amount) in [("12,34", 12.34), (".50", 0.5), ("999999.99", 999999.99), ("0.01", 0.01)] {
            draft.entry = input
            expect(draft.isValid && close(draft.amount, amount), "Accept valid amount: \(input)")
        }
        for pennies in [1, 3, 99, 100, 12345] {
            draft.entry = String(format: "%.2f", Double(pennies) / 100)
            for share in 0...100 {
                draft.splitPercent = share
                expect(close(draft.yourAmount + draft.partnerAmount, draft.amount), "Split must conserve every penny")
                expect(draft.yourAmount >= 0 && draft.partnerAmount >= 0, "Shares must not be negative")
            }
        }
        draft.paidBy = .partner
        draft.merchant = "  Coffee shop  "
        expect(draft.asTransaction().actor == .partner, "Joint expenses retain the selected payer")
        expect(draft.asTransaction().title == "Coffee shop", "Merchant is trimmed and retained")

        let state = AppState(snapshot: MockData.snapshot)
        state.ledger = .joint
        let initialBalance = state.safeToSpend.remaining
        let initialSpent = state.spentTotal
        let grocerySpend = state.envelopes.first { $0.name == "Groceries" }!.spent
        state.openAddSpend()
        state.draft.entry = "12.34"
        state.draft.category = "Groceries"
        state.commitSpend()
        expect(state.addedTransactions.count == 1, "Commit adds exactly one transaction")
        expect(close(state.safeToSpend.remaining, initialBalance - 12.34), "Safe-to-spend must reflect the expense")
        expect(close(state.spentTotal, initialSpent + 12.34), "Budget totals must reflect the expense")
        expect(close(state.envelopes.first { $0.name == "Groceries" }!.spent, grocerySpend + 12.34), "Correct category updates")
        expect(state.selectedTab == .ledger && !state.isAddingSpend, "Commit reveals the saved entry")
        state.commitSpend()
        expect(state.addedTransactions.count == 1, "A reset draft must not create a duplicate")

        state.ledger = .you
        expect(close(state.safeToSpend.remaining, 317), "Joint spending must not reduce personal balance")
        state.openAddSpend()
        expect(state.draft.ledger == .you, "New spend starts in the selected ledger")
        state.draft.entry = "0.01"
        state.draft.category = "Other"
        state.commitSpend()
        expect(close(state.safeToSpend.remaining, 316.99), "Personal expense reduces its own balance")
        expect(state.envelopes.contains { $0.name == "Other" && close($0.spent, 0.01) && $0.budget == 0 }, "Unbudgeted spending must remain visible")
        state.openAddSpend()
        state.draft.entry = "40"
        state.cancelAddSpend()
        expect(state.addedTransactions.count == 2, "Cancelling must not change the ledger")
        state.draft.entry = "-30"
        state.commitSpend()
        expect(state.addedTransactions.count == 2, "Invalid spending must never commit")
        state.ledger = .joint
        expect(state.priorityEnvelopes.first?.name == "Eating out", "Overspent category is surfaced first")
        expect(state.homeEnvelopes.allSatisfy(\.isOver), "Attention card must exclude fully paid categories")
        expect(Envelope(name: "Other", spent: 1, budget: 0, detail: "", pace: "").fraction == 1, "Unbudgeted spending must not show an empty track")
        let september = MonthCalendar(date: Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: 2026, month: 9, day: 14))!)
        expect(september.startOffset == 1, "September 2026 starts in Tuesday's column")
        expect(september.daysLeft == 17 && september.monthName == "September", "Month facts come from the date")
        state.feedFilter = .partner
        state.ledger = .joint
        expect(state.filteredTransactions.isEmpty, "Sam starts with an empty ledger")
        state.openAddSpend(for: state.feedFilter)
        expect(state.draft.ledger == .partner, "Expense entry follows the active ledger filter")
        expect(!state.draft.hasContent, "A fresh draft can be dismissed freely")
        state.draft.entry = "0."
        expect(state.draft.hasContent, "Incomplete amount input must be protected from dismissal")
        state.draft.entry = ""
        state.draft.merchant = "Lunch"
        expect(state.draft.hasContent, "A note without an amount must be protected")
        state.draft.merchant = "  "
        expect(!state.draft.hasContent, "Whitespace alone is not meaningful work")

        let originalContribution = state.potContribution
        var contributions = ContributionDraft(members: state.members)
        expect(contributions.isValid && !contributions.hasChanges, "A fresh contribution draft matches the household")
        contributions.entries[.you] = "1975.25"
        expect(close(state.potContribution, originalContribution), "Editing must not change balances before save")
        contributions.entries[.partner] = "bad input"
        expect(!contributions.isValid && contributions.total == nil, "Invalid edits must not show a stale total")
        expect(!state.saveContributions(contributions), "Invalid contribution drafts cannot save")
        expect(close(state.potContribution, originalContribution), "An invalid save must leave every member unchanged")
        contributions.entries[.partner] = "0"
        expect(contributions.isValid, "Zero is a valid monthly contribution")
        expect(state.saveContributions(contributions), "A valid contribution draft saves")
        expect(close(state.potContribution, 1975.25), "Save applies both contributions together")
        contributions = ContributionDraft(members: state.members)
        contributions.adjust(.partner, by: -50)
        expect(contributions.entries[.partner] == "0.00", "Contribution decrement stops at zero")
        contributions.entries[.you] = "999999.99"
        contributions.adjust(.you, by: 50)
        expect(contributions.entries[.you] == "999999.99", "Contribution increment respects the maximum")
        contributions.entries[.you] = "1.234"
        contributions.adjust(.you, by: 50)
        expect(contributions.entries[.you] == "1.234", "Steppers do not silently replace invalid input")
        expect(!state.saveContributions(ContributionDraft(members: [])), "A mismatched household draft cannot save")

        let household = AppState()
        expect(household.householdSize == 2 && household.ledgers == [.you, .joint, .partner], "A new household is two people")
        household.ledger = .partner
        household.householdSize = 4
        expect(household.ledgers == [.you, .joint, .partner, .third, .fourth], "Growing adds ledgers in household order")
        expect(household.householdSummary == "Four personal accounts + one joint pot", "Summary counts the people")
        household.openAddSpend(for: .joint)
        expect(!household.draft.showsSplit && household.draft.asTransaction().splitPercent == nil, "No you/partner split beyond two people")
        household.cancelAddSpend()
        household.householdSize = 5
        expect(household.householdSize == 4, "More than four people is refused")
        household.feedFilter = .fourth
        household.householdSize = 1
        expect(household.ledgers == [.you, .joint] && household.members.map(\.ledger) == [.you], "A household of one keeps only you and the pot")
        expect(household.ledger == .joint && household.feedFilter == nil, "Selections on a removed ledger fall back")
        expect(household.householdSummary == "One personal account + one joint pot", "Summary is singular for one")
        household.ledger = .you
        household.openAddSpend()
        household.draft.entry = "5"
        household.commitSpend()
        expect(household.safeToSpend.caption == "Personal allowance.", "Nobody else to see a solo allowance")
        household.householdSize = 0
        expect(household.householdSize == 1, "Fewer than one person is refused")

        let empty = AppState()
        expect(empty.safeToSpend.isEmpty && empty.envelopes.isEmpty && empty.upcomingBills.isEmpty, "A new household has nothing to show")
        expect(empty.recap == nil && empty.snapshot.netWorth == nil, "A new household has no recap or net worth")
        expect(empty.name(for: .you) == "You" && empty.name(for: .partner) == "Partner", "Unnamed members read generically")
        expect(empty.you.possessive == "Your" && empty.partner.possessive == "Partner’s", "Possessives stay grammatical without names")
        empty.saveContributions({ var d = ContributionDraft(members: empty.members); d.entries[.you] = "100"; return d }())
        expect(!empty.safeToSpend.isEmpty && close(empty.safeToSpend.remaining, 100), "Contributions fund an otherwise empty pot")
        empty.openAddSpend()
        empty.draft.entry = "12"
        empty.commitSpend()
        expect(empty.envelopes.first?.name == "Groceries" && empty.envelopes.first?.budget == 0, "First spend creates an unbudgeted envelope")
        expect(empty.transactionGroups.first?.label.hasPrefix("Today · ") == true, "A new spend groups under today")

        var goalDraft = GoalDraft(name: "  House deposit ", target: "20000", saved: "", monthly: "250")
        expect(goalDraft.goal()?.name == "House deposit" && goalDraft.goal()?.saved == 0, "A goal trims its name and starts from nothing")
        for (target, monthly) in [("0", "250"), ("", "250"), ("abc", "250"), ("20000", ""), ("20000", "-5")] {
            expect(GoalDraft(name: "Car", target: target, monthly: monthly).goal() == nil, "Reject goal \(target)/\(monthly)")
        }
        expect(GoalDraft(name: "  ", target: "100", monthly: "50").goal() == nil, "A goal needs a name")
        expect(!GoalDraft().hasContent && GoalDraft(target: "1").hasContent, "Any typed goal field is protected")
        expect(empty.createGoal(goalDraft) && empty.goals.count == 1 && empty.goals[0].monthsToGo == 80, "A valid goal is added")
        goalDraft.target = "0"
        expect(!empty.createGoal(goalDraft) && empty.goals.count == 1, "An invalid goal never saves")

        empty.ledger = .joint
        expect(empty.unbudgetedCategories == SpendDraft.categories, "A new ledger can budget every category")
        expect(!empty.createEnvelope(EnvelopeDraft(category: "Groceries", budget: "0")), "A zero budget is rejected")
        expect(!empty.createEnvelope(EnvelopeDraft(category: "Pets", budget: "50")), "Only spend categories become envelopes")
        expect(empty.createEnvelope(EnvelopeDraft(category: "Groceries", budget: "300")), "An envelope saves on an empty ledger")
        expect(empty.envelopes.count == 1 && empty.envelopes[0].budget == 300 && close(empty.envelopes[0].spent, 12),
               "A new budget absorbs earlier unbudgeted spending")
        expect(close(empty.leftTotal, 288) && !empty.unbudgetedCategories.contains("Groceries"), "Budgeted categories leave the picker")
        expect(!empty.createEnvelope(EnvelopeDraft(category: "Groceries", budget: "10")), "A category cannot be budgeted twice")
        empty.ledger = .you
        expect(empty.envelopes.isEmpty && empty.unbudgetedCategories.contains("Groceries"), "Envelopes belong to one ledger")
        expect(empty.createEnvelope(EnvelopeDraft(category: "Transport", budget: "80")) && empty.envelopes.count == 1, "A personal envelope saves")
        empty.ledger = .joint
        expect(empty.envelopes.count == 1, "A personal envelope stays out of the pot")

        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        let late = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 11, day: 20, hour: 23, minute: 30))!
        let billDue = BillDraft(dueDay: late).dueDate
        expect(utc.dateComponents([.day, .hour], from: billDue) == DateComponents(day: 20, hour: 12), "Bills are sent as noon UTC on the chosen day")
        expect(BillDraft(name: "Rent", amount: "0").bill() == nil && BillDraft(name: "", amount: "5").bill() == nil, "A bill needs a name and an amount")
        let later = empty.month.adding(days: 3)
        expect(empty.createBill(BillDraft(name: "Council tax", amount: "180", dueDay: later)), "A valid bill saves")
        expect(empty.createBill(BillDraft(name: "Water", amount: "40", dueDay: empty.month.date, isEstimated: true)), "An estimated bill saves")
        expect(empty.snapshot.bills.map(\.name) == ["Water", "Council tax"], "Bills stay in due-date order")
        expect(empty.snapshot.bills[0].meta == "Estimated" && empty.snapshot.bills[1].meta.isEmpty, "Only estimates are labelled")
        expect(empty.upcomingBills.count == 2, "A bill due today is still upcoming")

        await empty.signUp(email: "a@b.c", password: "password1")
        empty.createGoal(GoalDraft(name: "Car", target: "10", monthly: "1"))
        empty.selectedTab = .goals
        empty.feedFilter = .you
        empty.signOut()
        expect(!empty.isAuthenticated && empty.userEmail.isEmpty && !empty.hasCompletedSetup, "Sign-out returns to the gate")
        expect(empty.snapshot == .empty && empty.goals.isEmpty && empty.allTransactions.isEmpty, "Sign-out leaves nothing from the account")
        expect(empty.selectedTab == .home && empty.feedFilter == nil && empty.ledger == .joint, "The next account starts at home")

        func settle(_ condition: () -> Bool) async {
            for _ in 0..<200 where !condition() { try? await Task.sleep(nanoseconds: 5_000_000) }
        }
        let offline = AppState(backend: OfflineBackend(), snapshot: MockData.snapshot)
        offline.openAddSpend()
        offline.draft.entry = "5"
        offline.commitSpend()
        await settle { offline.syncError != nil }
        expect(offline.addedTransactions.isEmpty && offline.syncError != nil, "A refused spend rolls back and tells the user")
        offline.syncError = nil
        let monthly = offline.goals[0].monthly
        offline.adjustGoal(offline.goals[0].id, by: Goal.step)
        await settle { offline.syncError != nil }
        expect(offline.goals[0].monthly == monthly, "A refused goal change rolls back")
        offline.syncError = nil
        let pot = offline.potContribution
        var refused = ContributionDraft(members: offline.members)
        refused.entries[.you] = "1"
        offline.saveContributions(refused)
        await settle { offline.syncError != nil }
        expect(close(offline.potContribution, pot), "Refused contributions roll back")
        offline.syncError = nil
        offline.householdSize = 1
        await settle { offline.syncError != nil }
        expect(offline.members.map(\.ledger) == [.you, .partner], "A refused household size rolls back")
        offline.syncError = nil
        let goalCount = offline.goals.count
        offline.createGoal(GoalDraft(name: "Car", target: "5000", monthly: "100"))
        await settle { offline.syncError != nil }
        expect(offline.goals.count == goalCount, "A refused goal is removed")
        offline.syncError = nil
        offline.ledger = .partner
        let category = offline.unbudgetedCategories[0]
        let envelopeCount = offline.envelopes.count
        offline.createEnvelope(EnvelopeDraft(category: category, budget: "50"))
        await settle { offline.syncError != nil }
        expect(offline.envelopes.count == envelopeCount && offline.unbudgetedCategories.contains(category), "A refused envelope is removed")
        offline.syncError = nil
        let billCount = offline.snapshot.bills.count
        offline.createBill(BillDraft(name: "Gym", amount: "30"))
        await settle { offline.syncError != nil }
        expect(offline.snapshot.bills.count == billCount, "A refused bill is removed")
        let name = offline.snapshot.name
        await offline.loadHousehold()
        expect(offline.loadState == .failed && offline.snapshot.name == name, "A failed load is not an empty household")
        await offline.signIn(email: "a@b.c", password: "secret")
        expect(!offline.isAuthenticated && offline.authError == BackendError.server(500).message, "A failed sign-in stays on the gate")
        await offline.restoreSession()
        expect(!offline.isAuthenticated && !offline.isRestoring, "A session that can't be checked leaves the sign-in gate")
        let local = AppState()
        await local.restoreSession()
        expect(!local.isAuthenticated && !local.isRestoring, "Nothing saved means signing in")
        await local.signUp(email: "a@b.c", password: "password1")
        expect(local.isAuthenticated && !local.hasCompletedSetup && local.loadState == .loaded, "Sign-up continues into setup")

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubProtocol.self]
        let tokens = MemoryTokenStore()
        let http = HTTPBackend(baseURL: URL(string: "https://stor.test/v1")!, session: URLSession(configuration: configuration), tokens: tokens)
        let nothing = try! await http.restoreSession()
        expect(nothing == nil, "With no saved token there is nothing to restore")
        StubProtocol.body = Data(#"{"email":"a@b.c","hasCompletedSetup":true,"token":"abc"}"#.utf8)
        let session = try! await http.signIn(email: "a@b.c", password: "secret")
        expect(session.hasCompletedSetup && StubProtocol.last?.url?.path == "/v1/auth/sign-in", "Sign-in posts to the contract path")
        expect(tokens.token == "abc", "Sign-in keeps the token for the next launch")
        let relaunched = HTTPBackend(baseURL: URL(string: "https://stor.test/v1")!, session: URLSession(configuration: configuration), tokens: tokens)
        StubProtocol.body = Data(#"{"email":"a@b.c","hasCompletedSetup":true}"#.utf8)
        let restored = try! await relaunched.restoreSession()
        expect(restored?.email == "a@b.c" && StubProtocol.last?.url?.path == "/v1/auth/session"
               && StubProtocol.last?.value(forHTTPHeaderField: "Authorization") == "Bearer abc", "A relaunch checks the saved token")
        expect(StubProtocol.last?.url?.query == nil, "Credentials never travel in the URL")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        StubProtocol.body = try! encoder.encode(MockData.snapshot)
        let loaded = try! await http.loadHousehold()
        expect(StubProtocol.last?.value(forHTTPHeaderField: "Authorization") == "Bearer abc", "Requests carry the session token")
        expect(loaded.transactions.count == MockData.transactions.count && loaded.accountGroups.count == 4, "The snapshot round-trips through JSON")
        expect(loaded.netWorth?.series.count == NetWorthRange.allCases.count, "Net-worth series decode per range")
        StubProtocol.body = try! encoder.encode(HouseholdSnapshot.empty)
        let blank = try! await http.loadHousehold()
        expect(blank == .empty, "The empty household round-trips through JSON")
        for (status, expected) in [(401, BackendError.invalidCredentials), (409, .emailTaken), (503, .server(503))] {
            StubProtocol.status = status
            do {
                _ = try await http.loadHousehold()
                expect(false, "A \(status) must throw")
            } catch {
                expect(error as? BackendError == expected, "A \(status) maps to its error")
            }
        }
        StubProtocol.status = 200
        expect(tokens.token == nil, "A rejected token is forgotten")
        StubProtocol.body = Data(#"{"email":"a@b.c","hasCompletedSetup":true,"token":"abc"}"#.utf8)
        _ = try! await http.signIn(email: "a@b.c", password: "secret")
        StubProtocol.body = try! encoder.encode(HouseholdSnapshot.empty)
        var bodies: [String: Data] = [:]
        StubProtocol.onRequest = { request in
            let body = request.httpBodyStream.map { stream -> Data in
                stream.open(); defer { stream.close() }
                var data = Data(), buffer = [UInt8](repeating: 0, count: 4096)
                while stream.hasBytesAvailable { let n = stream.read(&buffer, maxLength: buffer.count); if n <= 0 { break }; data.append(buffer, count: n) }
                return data
            } ?? request.httpBody ?? Data()
            bodies["\(request.httpMethod!) \(request.url!.path)"] = body
        }
        try! await http.setHouseholdSize(3)
        let sizeBody = try! JSONSerialization.jsonObject(with: bodies["PUT /v1/household/size"]!) as! [String: Any]
        expect(sizeBody["size"] as? Int == 3, "Household size travels as {size}")
        bodies = [:]
        try! await http.createGoal(GoalDraft(name: "Car", target: "10", monthly: "1").goal(id: "g1")!)
        try! await http.setEnvelopeBudget(ledger: .joint, name: "Home & repairs", budget: 120)
        try! await http.createBill(BillDraft(name: "Rent", amount: "900", dueDay: late).bill(id: "b1")!)
        expect(Set(bodies.keys) == ["POST /v1/goals", "PUT /v1/ledgers/joint/envelopes", "POST /v1/bills"], "Creates use the contract paths")
        let envelopeBody = try! JSONSerialization.jsonObject(with: bodies["PUT /v1/ledgers/joint/envelopes"]!) as! [String: Any]
        expect(envelopeBody["name"] as? String == "Home & repairs" && envelopeBody["budget"] as? Double == 120, "Envelope names travel in the body")
        let billBody = try! JSONSerialization.jsonObject(with: bodies["POST /v1/bills"]!) as! [String: Any]
        expect(billBody["id"] as? String == "b1" && billBody["dueDate"] as? String == "2026-11-20T12:00:00Z", "Bills carry their id and a noon UTC date")
        try! await http.signOut()
        expect(StubProtocol.last?.url?.path == "/v1/auth/sign-out"
               && StubProtocol.last?.value(forHTTPHeaderField: "Authorization") == "Bearer abc", "Sign-out revokes the current token")
        expect(tokens.token == nil, "Sign-out forgets the saved token")
        _ = try! await http.loadHousehold()
        expect(StubProtocol.last?.value(forHTTPHeaderField: "Authorization") == nil, "Signed-out requests carry no token")
        print("Passed \(checks) model regression checks")
    }
}

struct OfflineBackend: StorBackend {
    func signIn(email: String, password: String) async throws -> AuthSession { throw BackendError.server(500) }
    func signUp(email: String, password: String) async throws -> AuthSession { throw BackendError.server(500) }
    func loadHousehold() async throws -> HouseholdSnapshot { throw BackendError.server(500) }
    func addSpend(_ spend: Transaction) async throws { throw BackendError.server(500) }
    func saveContributions(_ contributions: [Ledger: Double]) async throws { throw BackendError.server(500) }
    func setGoalMonthly(id: String, monthly: Double) async throws { throw BackendError.server(500) }
    func signOut() async throws { throw BackendError.server(500) }
    func restoreSession() async throws -> AuthSession? { throw BackendError.server(500) }
    func createGoal(_ goal: Goal) async throws { throw BackendError.server(500) }
    func setEnvelopeBudget(ledger: Ledger, name: String, budget: Double) async throws { throw BackendError.server(500) }
    func createBill(_ bill: Bill) async throws { throw BackendError.server(500) }
    func setLinkedAccounts(_ ids: Set<String>) async throws { throw BackendError.server(500) }
    func setTopUpDay(_ day: Int) async throws { throw BackendError.server(500) }
    func setHouseholdSize(_ size: Int) async throws { throw BackendError.server(409) }
    func completeSetup() async throws { throw BackendError.server(500) }
}

final class MemoryTokenStore: TokenStore, @unchecked Sendable {
    var token: String?
    func load() -> String? { token }
    func save(_ token: String?) { self.token = token }
}

final class StubProtocol: URLProtocol {
    nonisolated(unsafe) static var body = Data()
    nonisolated(unsafe) static var status = 200
    nonisolated(unsafe) static var last: URLRequest?
    nonisolated(unsafe) static var onRequest: (URLRequest) -> Void = { _ in }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}
    override func startLoading() {
        Self.last = request
        Self.onRequest(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: Self.status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.body)
        client?.urlProtocolDidFinishLoading(self)
    }
}
