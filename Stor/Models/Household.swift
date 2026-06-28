import Foundation

/// How the household's monthly surplus is divided between members.
enum SurplusSplitMethod: String, CaseIterable, Identifiable {
    /// Split in proportion to each member's net income.
    case proportional = "By income"
    /// Split equally between members.
    case even = "Evenly"

    var id: String { rawValue }
    var label: String { rawValue }

    var explanation: String {
        switch self {
        case .proportional: return "Shared in proportion to each member's income"
        case .even:         return "Shared equally between members"
        }
    }
}

struct Household: Identifiable {
    let id: UUID
    var name: String
    var members: [Member]
    var memberSince: Date
    var framework: Framework
    var requiresApprovals: Bool
    var surplusSplitMethod: SurplusSplitMethod
    var inviteCode: String
}
