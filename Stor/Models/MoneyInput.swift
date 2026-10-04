import Foundation

/// Decimal money input shared by expense and contribution fields.
enum MoneyInput {
    static let maximum = 999_999.99

    static func amount(from input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: ",", with: ".")
        guard normalized.allSatisfy({ "0123456789.".contains($0) }) else { return nil }
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2, (parts.first?.count ?? 0) <= 6,
              parts.count < 2 || parts[1].count <= 2,
              let value = Double(normalized), value.isFinite,
              value >= 0, value <= maximum else { return nil }
        return value
    }

    static func entry(for amount: Double) -> String {
        String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), amount)
    }
}
