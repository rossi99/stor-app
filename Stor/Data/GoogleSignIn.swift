import CryptoKit
import Foundation

/// Google sign-in as OAuth with PKCE in a browser sheet, so no Google SDK is needed.
/// The ID token it ends with is what the API verifies.
struct GoogleSignIn: Sendable {
    let clientID: String
    let verifier = Self.random()
    let state = Self.random()

    /// Google redirects iOS clients to the client ID reversed.
    var redirectScheme: String { clientID.split(separator: ".").reversed().joined(separator: ".") }
    private var redirectURI: String { redirectScheme + ":/oauthredirect" }

    var authorizeURL: URL {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid email"),
            URLQueryItem(name: "code_challenge", value: Self.challenge(for: verifier)),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
        ]
        return components.url!
    }

    /// Trades the code in Google's redirect for an ID token.
    func idToken(from callback: URL, session: URLSession = .shared) async throws -> String {
        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard items.first(where: { $0.name == "state" })?.value == state,
              let code = items.first(where: { $0.name == "code" })?.value else {
            throw BackendError.invalidCredentials
        }
        var form = URLComponents()
        form.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code_verifier", value: verifier),
        ]
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data((form.percentEncodedQuery ?? "").utf8)
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw BackendError.invalidCredentials
        }
        struct Tokens: Decodable { let id_token: String }
        return try JSONDecoder().decode(Tokens.self, from: data).id_token
    }

    static func challenge(for verifier: String) -> String {
        base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))
    }

    static func random() -> String {
        base64URL(Data((0..<32).map { _ in UInt8.random(in: .min ... .max) }))
    }

    private static func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
