import SwiftUI
import UIKit

// MARK: - Typography
//
// Two families carry the whole interface.
//
// **SF Pro Display** at weight 650 for every heading and display figure. 650
// sits between semibold (600) and bold (700); `UIFont.Weight` takes a raw
// CGFloat, so the bridge below hits it exactly rather than rounding to one of
// SwiftUI's named weights. iOS switches to the Display optical size above 20pt
// on its own.
//
// **SF Mono**, uppercased and widely tracked, for micro-labels, money and
// metadata. Tabular figures come free with a monospaced design, so columns of
// currency align without further work.

extension Font {

    /// SF Pro Display at a fixed size and true numeric weight.
    static func display(_ size: CGFloat, weight: CGFloat = 650) -> Font {
        Font(UIFont.systemFont(ofSize: size, weight: UIFont.Weight(uiWeight(weight))))
    }

    /// SF Mono at a fixed size — micro-labels, money, metadata.
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// SF Pro Text — body copy, row titles, anything conversational.
    static func text(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Maps a CSS numeric weight (100–900) onto `UIFont.Weight`'s -1...1 scale.
    private static func uiWeight(_ css: CGFloat) -> CGFloat {
        let stops: [(CGFloat, CGFloat)] = [
            (100, -0.80), (200, -0.60), (300, -0.23), (400, 0.00),
            (500,  0.23), (600,  0.30), (700,  0.40), (800, 0.56), (900, 0.62),
        ]
        if css <= stops[0].0 { return stops[0].1 }
        if css >= stops[stops.count - 1].0 { return stops[stops.count - 1].1 }
        for i in 1..<stops.count where css <= stops[i].0 {
            let (lowCSS, lowUI) = stops[i - 1], (highCSS, highUI) = stops[i]
            let t = (css - lowCSS) / (highCSS - lowCSS)
            return lowUI + t * (highUI - lowUI)
        }
        return 0
    }
}

// MARK: - Tracking

extension View {
    /// Letter-spacing expressed in `em`, the unit the design is specified in.
    func tracking(em: CGFloat, size: CGFloat) -> some View {
        tracking(em * size)
    }
}

// MARK: - Navigation bar appearance

enum Typography {
    /// Every screen draws its own header, so the system navigation bar only ever
    /// needs to be invisible and out of the way.
    static func configureNavigationBar() {
        let transparent = UINavigationBarAppearance()
        transparent.configureWithTransparentBackground()
        transparent.shadowColor = nil

        let bar = UINavigationBar.appearance()
        bar.standardAppearance   = transparent
        bar.compactAppearance    = transparent
        bar.scrollEdgeAppearance = transparent
    }
}
