import SwiftUI

/// The spine of the app. Every figure belongs to exactly one ledger, so nothing
/// is ambiguously "ours" — a personal ledger per member beside a funded joint pot.
/// Members other than you are named by their order in the household.
enum Ledger: String, CaseIterable, Identifiable, Hashable, Codable, Sendable {
    case you, joint, partner, third, fourth

    var id: String { rawValue }

    /// Personal ledgers in household order; a household of n uses the first n.
    static let people: [Ledger] = [.you, .partner, .third, .fourth]

    var isPersonal: Bool { self != .joint }

    /// Shown until the server knows a real name.
    var defaultName: String {
        switch self {
        case .you:     "You"
        case .joint:   "Joint"
        case .partner: "Partner"
        case .third:   "Person 3"
        case .fourth:  "Person 4"
        }
    }

    /// Structural identity colour — terracotta, teal, blue, ochre, plum.
    var accent: Color {
        switch self {
        case .you:   .storAna
        case .joint: .storAccent
        case .partner: .storSam
        case .third: .storThird
        case .fourth: .storFourth
        }
    }

    /// Tinted background for rows and chips carrying this ledger's identity.
    var soft: Color {
        switch self {
        case .you:   .storAnaSoft
        case .joint: .storAccentSoft
        case .partner: .storSamSoft
        case .third: .storThirdSoft
        case .fourth: .storFourthSoft
        }
    }
}
