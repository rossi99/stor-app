import Foundation

/// JSON over HTTPS. The token is kept in `tokens`, so a relaunch stays signed in until it expires.
actor HTTPBackend: StorBackend {
    private let baseURL: URL
    private let session: URLSession
    private let tokens: any TokenStore
    private var token: String?

    init(baseURL: URL, session: URLSession = .shared, tokens: any TokenStore = KeychainTokenStore()) {
        self.baseURL = baseURL
        self.session = session
        self.tokens = tokens
        token = tokens.load()
    }

    private struct Credentials: Encodable { let email, password: String }
    private struct Contribution: Encodable { let ledger: Ledger; let amount: Double }
    private struct Monthly: Encodable { let monthly: Double }
    private struct AccountIDs: Encodable { let ids: [String] }
    private struct TopUpDay: Encodable { let day: Int }
    private struct HouseholdSize: Encodable { let size: Int }
    private struct EnvelopeBudget: Encodable { let name: String; let budget: Double }
    private struct InviteCode: Encodable { let code: String }
    private struct Password: Encodable { let password: String }
    private struct TransferTick: Encodable { let month: String; let key: String; let done: Bool }
    private struct Empty: Encodable {}

    func signIn(email: String, password: String) async throws -> AuthSession {
        try await authenticate("auth/sign-in", email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        try await authenticate("auth/sign-up", email: email, password: password)
    }

    /// Forgets the token first, so a failed revoke still signs the device out.
    func signOut() async throws {
        guard let current = token else { return }
        remember(nil)
        _ = try await send("POST", "auth/sign-out", Empty?.none, bearer: current)
    }

    /// The server deletes the account and every session, so the token goes too.
    func deleteAccount(password: String) async throws {
        _ = try await send("DELETE", "auth/account", Password(password: password))
        remember(nil)
    }

    /// The stored session, if its token is still good; nil when there is none to check.
    func restoreSession() async throws -> AuthSession? {
        guard token != nil else { return nil }
        return try Self.decoder.decode(AuthSession.self, from: try await send("GET", "auth/session", Empty?.none))
    }

    func loadHousehold() async throws -> HouseholdSnapshot {
        try Self.decoder.decode(HouseholdSnapshot.self, from: try await send("GET", "household", Empty?.none))
    }

    func addSpend(_ spend: Transaction) async throws {
        _ = try await send("POST", "transactions", spend)
    }

    func saveContributions(_ contributions: [Ledger: Double]) async throws {
        let body = contributions.map { Contribution(ledger: $0.key, amount: $0.value) }
        _ = try await send("PUT", "household/contributions", body)
    }

    func saveMembers(_ profiles: [MemberProfile]) async throws {
        _ = try await send("PUT", "household/members", profiles)
    }

    func createInvite() async throws -> Invite {
        do {
            return try Self.decoder.decode(Invite.self, from: try await send("POST", "household/invites", Empty?.none))
        } catch BackendError.emailTaken {
            throw BackendError.householdFull
        }
    }

    /// The session's token is unchanged; it now belongs to the joined household.
    func joinHousehold(code: String) async throws -> AuthSession {
        do {
            return try Self.decoder.decode(AuthSession.self, from: try await send("POST", "household/join", InviteCode(code: code)))
        } catch BackendError.emailTaken {
            throw BackendError.householdUnavailable
        }
    }

    func setGoalMonthly(id: String, monthly: Double) async throws {
        let goal = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(["/"])) ?? id
        _ = try await send("PUT", "goals/\(goal)/monthly", Monthly(monthly: monthly))
    }

    func createGoal(_ goal: Goal) async throws {
        _ = try await send("POST", "goals", goal)
    }

    func setEnvelopeBudget(ledger: Ledger, name: String, budget: Double) async throws {
        _ = try await send("PUT", "ledgers/\(ledger.rawValue)/envelopes", EnvelopeBudget(name: name, budget: budget))
    }

    func saveBill(_ bill: Bill) async throws {
        _ = try await send("PUT", "bills/\(Self.pathSegment(bill.id))", bill)
    }

    func deleteBill(id: String) async throws {
        _ = try await send("DELETE", "bills/\(Self.pathSegment(id))", Empty?.none)
    }

    func loadPlan(month: String) async throws -> BudgetPlan {
        let data = try await send("GET", "plan", Empty?.none, query: [URLQueryItem(name: "month", value: month)])
        return try Self.decoder.decode(BudgetPlan.self, from: data)
    }

    func setTransfer(month: String, key: String, done: Bool) async throws {
        _ = try await send("PUT", "plan/transfers", TransferTick(month: month, key: key, done: done))
    }

    func saveBudget(_ settings: BudgetSettings) async throws {
        _ = try await send("PUT", "household/budget", settings)
    }

    private static func pathSegment(_ id: String) -> String {
        id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(["/"])) ?? id
    }

    func setLinkedAccounts(_ ids: Set<String>) async throws {
        _ = try await send("PUT", "household/linked-accounts", AccountIDs(ids: ids.sorted()))
    }

    func setTopUpDay(_ day: Int) async throws {
        _ = try await send("PUT", "household/top-up-day", TopUpDay(day: day))
    }

    func setHouseholdSize(_ size: Int) async throws {
        _ = try await send("PUT", "household/size", HouseholdSize(size: size))
    }

    func completeSetup() async throws {
        _ = try await send("POST", "household/setup-complete", Empty?.none)
    }

    private func authenticate(_ path: String, email: String, password: String) async throws -> AuthSession {
        let data = try await send("POST", path, Credentials(email: email, password: password))
        let session = try Self.decoder.decode(AuthSession.self, from: data)
        remember(session.token)
        return session
    }

    private func remember(_ newToken: String?) {
        token = newToken
        tokens.save(newToken)
    }

    private func send(_ method: String, _ path: String, _ body: (some Encodable)?,
                      bearer: String? = nil, query: [URLQueryItem] = []) async throws -> Data {
        var url = baseURL.appending(path: path)
        if !query.isEmpty { url.append(queryItems: query) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = bearer ?? token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body {
            request.httpBody = try Self.encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        switch status {
        case 200..<300: return data
        case 401:
            // The server no longer accepts this token, so stop keeping it.
            if bearer == nil, token != nil { remember(nil) }
            throw BackendError.invalidCredentials
        case 404: throw BackendError.notFound
        case 429: throw BackendError.tooManyAttempts
        case 409: throw BackendError.emailTaken
        default: throw BackendError.server(status)
        }
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
