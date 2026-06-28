import Foundation

struct Framework {
    var needsPercent: Double
    var wantsPercent: Double
    var savingsPercent: Double

    var label: String {
        let n = Int(needsPercent * 100)
        let w = Int(wantsPercent * 100)
        let s = Int(savingsPercent * 100)
        return "\(n)/\(w)/\(s)"
    }

    static let fiftyThirtyTwenty = Framework(needsPercent: 0.50, wantsPercent: 0.30, savingsPercent: 0.20)
    static let sixtyTwentyTwenty = Framework(needsPercent: 0.60, wantsPercent: 0.20, savingsPercent: 0.20)
    static let seventyTwentyTen  = Framework(needsPercent: 0.70, wantsPercent: 0.20, savingsPercent: 0.10)

    static let allOptions: [Framework] = [.fiftyThirtyTwenty, .sixtyTwentyTwenty, .seventyTwentyTen]
}
