import Foundation

/// JSON over HTTPS. The token lives in memory only, so a relaunch signs out.
actor HTTPBackend: StorBackend {
    private let baseURL: URL
    private let session: URLSession
    private var token: String?

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    private struct Credentials: Encodable { let email, password: String }
    private struct Contribution: Encodable { let ledger: Ledger; let amount: Double }
    private struct Monthly: Encodable { let monthly: Double }
    private struct AccountIDs: Encodable { let ids: [String] }
    private struct TopUpDay: Encodable { let day: Int }
    private struct Empty: Encodable {}

    func signIn(email: String, password: String) async throws -> AuthSession {
        try await authenticate("auth/sign-in", email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        try await authenticate("auth/sign-up", email: email, password: password)
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

    func setGoalMonthly(id: String, monthly: Double) async throws {
        let goal = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(["/"])) ?? id
        _ = try await send("PUT", "goals/\(goal)/monthly", Monthly(monthly: monthly))
    }

    func setLinkedAccounts(_ ids: Set<String>) async throws {
        _ = try await send("PUT", "household/linked-accounts", AccountIDs(ids: ids.sorted()))
    }

    func setTopUpDay(_ day: Int) async throws {
        _ = try await send("PUT", "household/top-up-day", TopUpDay(day: day))
    }

    func completeSetup() async throws {
        _ = try await send("POST", "household/setup-complete", Empty?.none)
    }

    private func authenticate(_ path: String, email: String, password: String) async throws -> AuthSession {
        let data = try await send("POST", path, Credentials(email: email, password: password))
        let session = try Self.decoder.decode(AuthSession.self, from: data)
        token = session.token
        return session
    }

    private func send(_ method: String, _ path: String, _ body: (some Encodable)?) async throws -> Data {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body {
            request.httpBody = try Self.encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        switch status {
        case 200..<300: return data
        case 401: throw BackendError.invalidCredentials
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
