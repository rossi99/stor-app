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
        let name = offline.snapshot.name
        await offline.loadHousehold()
        expect(offline.loadState == .failed && offline.snapshot.name == name, "A failed load is not an empty household")
        await offline.signIn(email: "a@b.c", password: "secret")
        expect(!offline.isAuthenticated && offline.authError == BackendError.server(500).message, "A failed sign-in stays on the gate")
        let local = AppState()
        await local.signUp(email: "a@b.c", password: "password1")
        expect(local.isAuthenticated && !local.hasCompletedSetup && local.loadState == .loaded, "Sign-up continues into setup")

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubProtocol.self]
        let http = HTTPBackend(baseURL: URL(string: "https://stor.test/v1")!, session: URLSession(configuration: configuration))
        StubProtocol.body = Data(#"{"email":"a@b.c","hasCompletedSetup":true,"token":"abc"}"#.utf8)
        let session = try! await http.signIn(email: "a@b.c", password: "secret")
        expect(session.hasCompletedSetup && StubProtocol.last?.url?.path == "/v1/auth/sign-in", "Sign-in posts to the contract path")
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
    func setLinkedAccounts(_ ids: Set<String>) async throws { throw BackendError.server(500) }
    func setTopUpDay(_ day: Int) async throws { throw BackendError.server(500) }
    func completeSetup() async throws { throw BackendError.server(500) }
}

final class StubProtocol: URLProtocol {
    nonisolated(unsafe) static var body = Data()
    nonisolated(unsafe) static var status = 200
    nonisolated(unsafe) static var last: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}
    override func startLoading() {
        Self.last = request
        let response = HTTPURLResponse(url: request.url!, statusCode: Self.status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.body)
        client?.urlProtocolDidFinishLoading(self)
    }
}
