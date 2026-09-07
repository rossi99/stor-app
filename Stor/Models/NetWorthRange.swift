import Foundation

/// Time window for the net-worth sparkline.
enum NetWorthRange: String, CaseIterable, Identifiable, Sendable {
    case oneMonth = "1M", sixMonths = "6M", oneYear = "1Y", all = "All"

    var id: String { rawValue }

    /// Caption beside the gain figure.
    var caption: String {
        switch self {
        case .oneMonth:  "this month"
        case .sixMonths: "in 6 months"
        case .oneYear:   "in 12 months"
        case .all:       "since 2019"
        }
    }
}
