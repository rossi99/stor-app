import SwiftUI

/// The spine of the app. Every figure belongs to exactly one ledger, so nothing
/// is ambiguously "ours" — two personal ledgers either side of a funded joint pot.
enum Ledger: String, CaseIterable, Identifiable, Hashable, Sendable {
    case ana, joint, sam

    var id: String { rawValue }

    /// Ordered as they appear in the segmented control.
    static let displayOrder: [Ledger] = [.ana, .joint, .sam]

    var isPersonal: Bool { self != .joint }

    /// Structural identity colour — terracotta, teal, blue.
    var accent: Color {
        switch self {
        case .ana:   .storAna
        case .joint: .storAccent
        case .sam:   .storSam
        }
    }

    /// Tinted background for rows and chips carrying this ledger's identity.
    var soft: Color {
        switch self {
        case .ana:   .storAnaSoft
        case .joint: .storAccentSoft
        case .sam:   .storSamSoft
        }
    }
}
