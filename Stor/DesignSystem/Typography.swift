import SwiftUI
import UIKit

/// Scale the existing type sizes with the environment, including SwiftUI previews
/// and changes made while the app is open. System fonts keep their native metrics.
private struct StorFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    let weight: Font.Weight
    let design: Font.Design

    init(size: CGFloat, relativeTo style: Font.TextStyle, weight: Font.Weight, design: Font.Design) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    func storDisplay(_ size: CGFloat, weight: CGFloat = 650) -> some View {
        modifier(StorFont(size: size, relativeTo: .largeTitle,
                          weight: weight >= 700 ? .bold : .semibold, design: .default))
    }

    func storText(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(StorFont(size: max(14, size), relativeTo: .body, weight: weight, design: .default))
    }

    func storMono(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(StorFont(size: max(12, size), relativeTo: .footnote, weight: weight, design: .monospaced))
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
