import SwiftUI

/// A linkable account offered during setup.
struct BankAccount: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    /// Whose account it is — shown under the name.
    let owner: String
    /// Which ledger's tint the monogram tile takes.
    let ledger: Ledger
    let initial: String
}
