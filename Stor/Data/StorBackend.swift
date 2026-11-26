import Foundation

struct AuthSession: Codable, Equatable, Sendable {
    let email: String
    let hasCompletedSetup: Bool
    var token: String?
}

struct MemberProfile: Codable, Equatable, Sendable {
    let ledger: Ledger
    let name: String
    let netPay: Double
}

/// A one-use code that lets someone take an empty seat in the household.
struct Invite: Codable, Equatable, Sendable {
    let code: String
    let expiresAt: Date
}

enum BackendError: Error, Equatable {
    case invalidCredentials, emailTaken, notFound, householdFull, householdUnavailable, server(Int)

    var message: String {
        switch self {
        case .invalidCredentials: "That email and password don’t match."
        case .emailTaken: "An account with that email already exists."
        case .notFound: "That code isn’t valid or has expired. Ask for a new one."
        case .householdFull: "Everyone in your household already has an account. Add a person in Household first."
        case .householdUnavailable: "That household is full, or yours already has spending or bills in it."
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
    func saveMembers(_ profiles: [MemberProfile]) async throws
    func createInvite() async throws -> Invite
    func joinHousehold(code: String) async throws -> AuthSession
    func setGoalMonthly(id: String, monthly: Double) async throws
    func createGoal(_ goal: Goal) async throws
    func setEnvelopeBudget(ledger: Ledger, name: String, budget: Double) async throws
    func saveBill(_ bill: Bill) async throws
    func deleteBill(id: String) async throws
    func loadPlan(month: String) async throws -> BudgetPlan
    func setTransfer(month: String, key: String, done: Bool) async throws
    func saveBudget(_ settings: BudgetSettings) async throws
    func setLinkedAccounts(_ ids: Set<String>) async throws
    func setTopUpDay(_ day: Int) async throws
    func setHouseholdSize(_ size: Int) async throws
    func completeSetup() async throws
}

/// Serves a fixed snapshot and accepts every write without a server.
/// shortcut: any password signs in, replace with HTTPBackend once the API is deployed.
struct LocalBackend: StorBackend {
    var snapshot: HouseholdSnapshot = .empty
    var plan: BudgetPlan?

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
    func saveMembers(_ profiles: [MemberProfile]) async throws {}
    func createInvite() async throws -> Invite { Invite(code: "DEMO-CODE", expiresAt: Date().addingTimeInterval(48 * 3600)) }
    func joinHousehold(code: String) async throws -> AuthSession { throw BackendError.notFound }
    func setGoalMonthly(id: String, monthly: Double) async throws {}
    func createGoal(_ goal: Goal) async throws {}
    func setEnvelopeBudget(ledger: Ledger, name: String, budget: Double) async throws {}
    func saveBill(_ bill: Bill) async throws {}
    func deleteBill(id: String) async throws {}
    func loadPlan(month: String) async throws -> BudgetPlan { plan ?? .empty(month: month) }
    func setTransfer(month: String, key: String, done: Bool) async throws {}
    func saveBudget(_ settings: BudgetSettings) async throws {}
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
            return LocalBackend(snapshot: MockData.snapshot, plan: MockData.plan)
        }
        if let url = process.environment["STOR_API_URL"].flatMap(URL.init(string:)) {
            return HTTPBackend(baseURL: url)
        }
        #endif
        return LocalBackend()
    }
}
