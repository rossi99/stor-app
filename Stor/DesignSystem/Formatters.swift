import SwiftUI

enum Currency: String, CaseIterable, Sendable {
    case gbp = "GBP", eur = "EUR", usd = "USD", jpy = "JPY"

    var symbol: String {
        switch self {
        case .gbp: "£"
        case .eur: "€"
        case .usd: "$"
        case .jpy: "¥"
        }
    }
}

/// Formats money the way the design specifies: a true minus sign rather than a
/// hyphen, en-GB grouping, and whole numbers rendered without trailing zeroes.
/// Privacy mode replaces every figure with bullets at the point of formatting,
/// so no view can accidentally leak an amount it never asked to show.
struct MoneyFormatter: Sendable {
    var currency: Currency = .gbp
    var privacyMode: Bool = false

    private static let grouping: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_GB")
        f.usesGroupingSeparator = true
        return f
    }()

    /// `decimals: nil` shows whole numbers bare and everything else to 2dp.
    func callAsFunction(_ value: Double, decimals: Int? = nil) -> String {
        guard !privacyMode else { return "••••" }

        let magnitude = abs(value)
        let places = decimals ?? (magnitude.rounded() == magnitude ? 0 : 2)

        let f = Self.grouping
        f.minimumFractionDigits = places
        f.maximumFractionDigits = places
        let digits = f.string(from: NSNumber(value: magnitude)) ?? "0"

        return (value < 0 ? "−" : "") + currency.symbol + digits
    }

    /// Compact thousands, for stat tiles where the exact pound doesn't matter.
    func thousands(_ value: Double) -> String {
        guard !privacyMode else { return "••••" }
        return currency.symbol + String(format: "%.1fk", value / 1000)
    }

    /// A signed figure, where the direction of change is the point.
    func signed(_ value: Double, decimals: Int? = nil) -> String {
        (value > 0 ? "+" : "") + callAsFunction(value, decimals: decimals)
    }
}

extension EnvironmentValues {
    @Entry var money = MoneyFormatter()
}

// MARK: - Percentages

extension Double {
    /// A whole-number percentage from a 0...1 fraction.
    var percentInt: String { String(format: "%.0f%%", self * 100) }
}

extension Int {
    var percentLabel: String { "\(self)%" }
}
