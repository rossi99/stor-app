import Foundation

@main
struct ModelRegressionTests {
    @MainActor static func main() {
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
                expect(close(draft.anaAmount + draft.samAmount, draft.amount), "Split must conserve every penny")
                expect(draft.anaAmount >= 0 && draft.samAmount >= 0, "Shares must not be negative")
            }
        }
        draft.paidBy = .sam
        draft.merchant = "  Coffee shop  "
        expect(draft.asTransaction().actor == .sam, "Joint expenses retain the selected payer")
        expect(draft.asTransaction().title == "Coffee shop", "Merchant is trimmed and retained")

        let state = AppState()
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

        state.ledger = .ana
        expect(close(state.safeToSpend.remaining, 317), "Joint spending must not reduce personal balance")
        state.openAddSpend()
        expect(state.draft.ledger == .ana, "New spend starts in the selected ledger")
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
        expect(MockData.monthStartOffset == 1, "September 2026 starts in Tuesday's column")
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: MockData.referenceDate)
        expect((MockData.monthStartOffset + MockData.todayDay - 1) % 7 == (weekday + 5) % 7, "Today aligns under the correct weekday")
        state.feedFilter = .sam
        state.ledger = .joint
        expect(state.filteredTransactions.isEmpty, "Sam starts with an empty ledger")
        state.openAddSpend(for: state.feedFilter)
        expect(state.draft.ledger == .sam, "Expense entry follows the active ledger filter")
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
        contributions.entries[.ana] = "1975.25"
        expect(close(state.potContribution, originalContribution), "Editing must not change balances before save")
        contributions.entries[.sam] = "bad input"
        expect(!contributions.isValid && contributions.total == nil, "Invalid edits must not show a stale total")
        expect(!state.saveContributions(contributions), "Invalid contribution drafts cannot save")
        expect(close(state.potContribution, originalContribution), "An invalid save must leave every member unchanged")
        contributions.entries[.sam] = "0"
        expect(contributions.isValid, "Zero is a valid monthly contribution")
        expect(state.saveContributions(contributions), "A valid contribution draft saves")
        expect(close(state.potContribution, 1975.25), "Save applies both contributions together")
        contributions = ContributionDraft(members: state.members)
        contributions.adjust(.sam, by: -50)
        expect(contributions.entries[.sam] == "0.00", "Contribution decrement stops at zero")
        contributions.entries[.ana] = "999999.99"
        contributions.adjust(.ana, by: 50)
        expect(contributions.entries[.ana] == "999999.99", "Contribution increment respects the maximum")
        contributions.entries[.ana] = "1.234"
        contributions.adjust(.ana, by: 50)
        expect(contributions.entries[.ana] == "1.234", "Steppers do not silently replace invalid input")
        expect(!state.saveContributions(ContributionDraft(members: [])), "A mismatched household draft cannot save")
        print("Passed \(checks) model regression checks")
    }
}
