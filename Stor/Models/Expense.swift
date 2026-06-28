import Foundation

enum ExpenseFrequency: String, CaseIterable, Identifiable {
    case weekly   = "Weekly"
    case monthly  = "Monthly"
    case annual   = "Annual"

    var id: String { rawValue }

    var monthlyMultiplier: Double {
        switch self {
        case .weekly:  return 52.0 / 12.0
        case .monthly: return 1.0
        case .annual:  return 1.0 / 12.0
        }
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case bills          = "Bills"
    case subscriptions  = "Subscriptions"
    case sinkingFunds   = "Sinking Funds"
    case groceries      = "Groceries"
    case transport      = "Transport"
    case eatingOut      = "Eating Out"
    case entertainment  = "Entertainment"
    case health         = "Health"
    case clothing       = "Clothing"
    case other          = "Other"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .bills:         return "bolt.fill"
        case .subscriptions: return "arrow.clockwise.circle.fill"
        case .sinkingFunds:  return "archivebox.fill"
        case .groceries:     return "cart.fill"
        case .transport:     return "car.fill"
        case .eatingOut:     return "fork.knife"
        case .entertainment: return "theatermasks.fill"
        case .health:        return "cross.fill"
        case .clothing:      return "tshirt.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }

    var frameworkBucket: FrameworkBucket {
        switch self {
        case .bills, .groceries, .transport, .health:
            return .needs
        case .subscriptions, .eatingOut, .entertainment, .clothing, .other:
            return .wants
        case .sinkingFunds:
            return .savings
        }
    }
}

enum FrameworkBucket: String {
    case needs   = "Needs"
    case wants   = "Wants"
    case savings = "Savings"
}

enum ApprovalStatus {
    case approved
    case pendingApproval(agreedBy: [UUID])

    var isApproved: Bool {
        if case .approved = self { return true }
        return false
    }
}

struct Expense: Identifiable {
    let id: UUID
    var name: String
    var total: Double
    var frequency: ExpenseFrequency
    var category: ExpenseCategory
    var addedBy: UUID

    var approvalStatus: ApprovalStatus

    var monthlyAmount: Double { total * frequency.monthlyMultiplier }
}
