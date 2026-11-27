import Foundation
import Security

/// Where the session token survives a relaunch.
protocol TokenStore: Sendable {
    func load() -> String?
    func save(_ token: String?)
}

/// This device's keychain only: never in backups or iCloud, and readable once the phone is first unlocked.
struct KeychainTokenStore: TokenStore {
    private static var item: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: "com.stor.app",
         kSecAttrAccount as String: "session-token"]
    }

    func load() -> String? {
        var query = Self.item
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func save(_ token: String?) {
        SecItemDelete(Self.item as CFDictionary)
        guard let token else { return }
        var item = Self.item
        item[kSecValueData as String] = Data(token.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(item as CFDictionary, nil)
    }
}
