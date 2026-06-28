import Foundation

struct TaxInfo {
    var grossMonthly: Double
    var taxCode: String
    var taxSystem: String
    var taxYear: String
    var maritalStatus: String
    var pensionContributionPercent: Double
    var hasStudentLoan: Bool
    var studentLoanPlan: String?

    var annualGross: Double { grossMonthly * 12 }
}
