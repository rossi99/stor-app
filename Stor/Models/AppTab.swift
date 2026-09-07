import Foundation

/// The five top-level destinations.
enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case home, ledger, budget, goals, wealth

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:   "Home"
        case .ledger: "Ledger"
        case .budget: "Budget"
        case .goals:  "Goals"
        case .wealth: "Wealth"
        }
    }

    var symbol: String {
        switch self {
        case .home:   "house"
        case .ledger: "list.bullet"
        case .budget: "chart.pie"
        case .goals:  "target"
        case .wealth: "chart.line.uptrend.xyaxis"
        }
    }
}

/// Screens pushed on top of a tab rather than owning one.
enum Route: Hashable, Sendable {
    case bills, alerts, household, recap
}
