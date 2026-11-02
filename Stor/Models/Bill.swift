import Foundation

/// A committed payment leaving the joint pot this month.
struct Bill: Identifiable, Hashable, Codable, Sendable {
    var id = UUID().uuidString
    let dueDate: Date
    let name: String
    /// "Camden · direct debit", "7 renewals".
    let meta: String
    let amount: Double
    /// Estimated rather than confirmed, so it renders muted.
    let isEstimated: Bool
}
