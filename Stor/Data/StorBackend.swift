import Foundation

struct AuthSession: Codable, Equatable, Sendable {
    let email: String
    let hasCompletedSetup: Bool
    var token: String?
}

enum BackendError: Error, Equatable {
    case invalidCredentials, emailTaken, server(Int)

    var message: String {
        switch self {
        case .invalidCredentials: "That email and password don’t match."
        case .emailTaken: "An account with that email already exists."
        case .server: "Something went wrong on our side. Try again in a moment."
        }
    }
}

/// Everything the app needs from a server. Contract: specs/api-contract.md.
protocol StorBackend: Sendable {
    func signIn(email: String, password: String) async throws -> AuthSession
    func signUp(email: String, password: String) async throws -> AuthSession
    func signOut() async throws
    func restoreSession() async throws -> AuthSession?
    func loadHousehold() async throws -> HouseholdSnapshot
    func addSpend(_ spend: Transaction) async throws
    func saveContributions(_ contributions: [Ledger: Double]) async throws
    func setGoalMonthly(id: String, monthly: Double) async throws
    func createGoal(_ goal: Goal) async throws
    func setEnvelopeBudget(ledger: Ledger, name: String, budget: Double) async throws
    func createBill(_ bill: Bill) async throws
    func setLinkedAccounts(_ ids: Set<String>) async throws
    func setTopUpDay(_ day: Int) async throws
    func setHouseholdSize(_ size: Int) async throws
    func completeSetup() async throws
}

/// Serves a fixed snapshot and accepts every write without a server.
/// shortcut: any password signs in, replace with HTTPBackend once the API is deployed.
struct LocalBackend: StorBackend {
    var snapshot: HouseholdSnapshot = .empty

    func signIn(email: String, password: String) async throws -> AuthSession {
        AuthSession(email: email, hasCompletedSetup: true)
    }
    func signUp(email: String, password: String) async throws -> AuthSession {
        AuthSession(email: email, hasCompletedSetup: false)
    }
    func signOut() async throws {}
    func restoreSession() async throws -> AuthSession? { nil }
    func loadHousehold() async throws -> HouseholdSnapshot { snapshot }
    func addSpend(_ spend: Transaction) async throws {}
    func saveContributions(_ contributions: [Ledger: Double]) async throws {}
    func setGoalMonthly(id: String, monthly: Double) async throws {}
    func createGoal(_ goal: Goal) async throws {}
    func setEnvelopeBudget(ledger: Ledger, name: String, budget: Double) async throws {}
    func createBill(_ bill: Bill) async throws {}
    func setLinkedAccounts(_ ids: Set<String>) async throws {}
    func setTopUpDay(_ day: Int) async throws {}
    func setHouseholdSize(_ size: Int) async throws {}
    func completeSetup() async throws {}
}

enum BackendConfig {
    /// Debug builds take `-useFixtures` or a `STOR_API_URL` environment variable.
    /// shortcut: Release has no server URL, set one here when the API is deployed.
    static func live() -> any StorBackend {
        #if DEBUG
        let process = ProcessInfo.processInfo
        if process.arguments.contains("-useFixtures") {
            return LocalBackend(snapshot: MockData.snapshot)
        }
        if let url = process.environment["STOR_API_URL"].flatMap(URL.init(string:)) {
            return HTTPBackend(baseURL: url)
        }
        #endif
        return LocalBackend()
    }
}
