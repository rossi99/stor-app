import SwiftUI

/// The spine of the app. Every figure belongs to exactly one ledger, so nothing
/// is ambiguously "ours" — two personal ledgers either side of a funded joint pot.
enum Ledger: String, CaseIterable, Identifiable, Hashable, Codable, Sendable {
    case you, joint, partner

    var id: String { rawValue }

    /// Ordered as they appear in the segmented control.
    static let displayOrder: [Ledger] = [.you, .joint, .partner]

    var isPersonal: Bool { self != .joint }

    /// Shown until the server knows a real name.
    var defaultName: String {
        switch self {
        case .you:     "You"
        case .joint:   "Joint"
        case .partner: "Partner"
        }
    }

    /// Structural identity colour — terracotta, teal, blue.
    var accent: Color {
        switch self {
        case .you:   .storAna
        case .joint: .storAccent
        case .partner: .storSam
        }
    }

    /// Tinted background for rows and chips carrying this ledger's identity.
    var soft: Color {
        switch self {
        case .you:   .storAnaSoft
        case .joint: .storAccentSoft
        case .partner: .storSamSoft
        }
    }
}
