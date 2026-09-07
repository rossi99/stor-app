import Foundation

/// A notification on the Alerts screen.
struct AlertItem: Identifiable, Hashable, Sendable {
    enum Kind: String, Sendable {
        case envelope = "Envelope"
        case payslip  = "Payslip"
        case jointPot = "Joint pot"
        case goal     = "Goal"
    }

    /// Whether the alert needs attention or is simply good news.
    enum Tone: Sendable { case attention, positive }

    let id = UUID()
    let kind: Kind
    let when: String
    let title: String
    let body: String
    let tone: Tone
    /// Good-news alerts sit on a tinted card rather than a plain one.
    var isHighlighted: Bool = false
}
