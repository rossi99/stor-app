import Foundation

/// One of the two people in the household.
struct HouseholdMember: Identifiable, Hashable, Codable, Sendable {
    let ledger: Ledger
    let name: String
    let initials: String
    /// "Owner · sees joint + own".
    let role: String
    /// Monthly net pay, used to express the pot contribution as a percentage.
    let netPay: Double
    /// Standing order into the joint pot each month.
    var contribution: Double

    var id: String { ledger.rawValue }

    var firstName: String { name.split(separator: " ").first.map(String.init) ?? ledger.defaultName }

    var displayName: String { name.isEmpty ? ledger.defaultName : name }

    /// "Ana’s", or "Your" while the signed-in person has no name yet.
    var possessive: String { name.isEmpty && ledger == .you ? "Your" : "\(firstName)’s" }

    static func placeholder(_ ledger: Ledger) -> HouseholdMember {
        HouseholdMember(ledger: ledger, name: "", initials: "", role: "", netPay: 0, contribution: 0)
    }

    /// Share of net pay going into the pot.
    var contributionPercent: Int {
        guard netPay > 0 else { return 0 }
        return Int(((contribution / netPay) * 100).rounded())
    }
}
