import Foundation

/// A notification on the Alerts screen.
struct AlertItem: Identifiable, Hashable, Codable, Sendable {
    enum Kind: String, Codable, Sendable {
        case envelope, payslip, jointPot, goal

        var label: String {
            switch self {
            case .envelope: "Envelope"
            case .payslip:  "Payslip"
            case .jointPot: "Joint pot"
            case .goal:     "Goal"
            }
        }
    }

    /// Whether the alert needs attention or is simply good news.
    enum Tone: String, Codable, Sendable { case attention, positive }

    var id = UUID().uuidString
    let kind: Kind
    let date: Date
    let title: String
    let body: String
    let tone: Tone
    /// Good-news alerts sit on a tinted card rather than a plain one.
    var isHighlighted: Bool = false
}
