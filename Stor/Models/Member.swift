import Foundation

struct Member: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var age: Int
    var gender: String
    var isCreator: Bool

    var firstName: String { name.components(separatedBy: " ").first ?? name }
}
