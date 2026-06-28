import Foundation

struct ForecastScenario {
    var additionalMonthlyExpense: Double
    var savingsAdjustment: Double
    var affectedPotID: UUID?

    var isModified: Bool {
        additionalMonthlyExpense != 0 || savingsAdjustment != 0
    }

    static let baseline = ForecastScenario(
        additionalMonthlyExpense: 0,
        savingsAdjustment: 0,
        affectedPotID: nil
    )
}
