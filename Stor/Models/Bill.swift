import Foundation

/// A committed payment leaving the joint pot this month.
struct Bill: Identifiable, Hashable, Sendable {
    let id = UUID()
    /// Day of the month it lands.
    let day: Int
    let name: String
    /// "Camden · direct debit", "7 renewals".
    let meta: String
    let amount: Double
    /// Estimated rather than confirmed, so it renders muted.
    let isEstimated: Bool
}
