import SwiftUI
import Observation

@Observable
@MainActor
final class AppState {

    // MARK: Auth
    var isAuthenticated = false
    var hasHousehold    = false
    var userName        = ""
    var userEmail       = ""

    // MARK: Session
    var currentMemberID: UUID = MockData.sarah.id

    // MARK: Data
    var household:        Household        = MockData.household
    var incomes:          [Income]         = MockData.incomes
    var expenses:         [Expense]        = MockData.expenses
    var previousMonthExpenses: Double       = MockData.previousMonthExpenses
    var savingsPots:      [SavingsPot]     = MockData.savingsPots
    var pensions:         [Pension]        = MockData.pensions
    var isas:             [ISA]            = MockData.isas
    var financialPosition: FinancialPosition = MockData.financialPosition
    var personalDetails:  PersonalDetails  = MockData.sarahPersonalDetails
    var taxInfo:          TaxInfo          = MockData.sarahTaxInfo

    // MARK: Derived
    var currentMember: Member? {
        household.members.first { $0.id == currentMemberID }
    }

    var pendingExpenseCount: Int {
        expenses.filter { !$0.approvalStatus.isApproved }.count
    }

    var approvedExpenses: [Expense] {
        expenses.filter { $0.approvalStatus.isApproved }
    }

    var householdNetMonthly: Double {
        incomes.reduce(0) { $0 + $1.netMonthly }
    }
}
