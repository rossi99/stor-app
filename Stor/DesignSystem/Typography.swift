import SwiftUI
import UIKit

// MARK: - Typography
//
// Headings and hero/display numbers use **New York** (Apple's system serif,
// `design: .serif`) — warm, slightly traditional, and drawn to pair with SF.
// Body, UI, small text and the tab bar use **SF Pro** (the system default).
// Numbers inside tables/rows use **SF Pro with tabular (monospaced) digits** so
// that columns line up; the large display number keeps New York because its
// alignment doesn't matter.

extension Font {

    // MARK: Headings — New York (serif)

    static let storLargeTitle = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let storTitle      = Font.system(.title,      design: .serif).weight(.semibold)
    static let storTitle2     = Font.system(.title2,     design: .serif).weight(.semibold)
    static let storTitle3     = Font.system(.title3,     design: .serif).weight(.semibold)

    /// A hero number at a fixed point size, in New York.
    /// Use for large display figures where column alignment doesn't matter.
    static func storHero(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// A display number/heading using a Dynamic Type text style, in New York.
    static func storDisplay(_ style: Font.TextStyle = .title2, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .serif).weight(weight)
    }

    // MARK: Tabular numbers — SF Pro, monospaced digits

    /// SF Pro with tabular (monospaced) digits, for numbers in lists/rows that
    /// should align vertically.
    static func storTabular(_ style: Font.TextStyle = .subheadline, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .default).weight(weight).monospacedDigit()
    }
}

// MARK: - Navigation bar appearance

enum Typography {
    /// New York at the given size/weight, scaled for Dynamic Type.
    private static func serif(size: CGFloat, weight: UIFont.Weight, style: UIFont.TextStyle) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let serif = base.fontDescriptor.withDesign(.serif).map { UIFont(descriptor: $0, size: size) } ?? base
        return UIFontMetrics(forTextStyle: style).scaledFont(for: serif)
    }

    /// Renders navigation-bar titles in New York app-wide. Body, tab bar and
    /// everything else stay SF Pro. Backgrounds are left at their system
    /// defaults (transparent at rest over the cream background, blurred when
    /// content scrolls underneath).
    static func configureNavigationBar() {
        let large  = serif(size: 34, weight: .bold,     style: .largeTitle)
        let inline = serif(size: 17, weight: .semibold, style: .headline)

        let scrolled = UINavigationBarAppearance()
        scrolled.configureWithDefaultBackground()
        scrolled.largeTitleTextAttributes = [.font: large]
        scrolled.titleTextAttributes      = [.font: inline]

        let atRest = UINavigationBarAppearance()
        atRest.configureWithTransparentBackground()
        atRest.largeTitleTextAttributes = [.font: large]
        atRest.titleTextAttributes      = [.font: inline]

        let bar = UINavigationBar.appearance()
        bar.standardAppearance   = scrolled
        bar.compactAppearance    = scrolled
        bar.scrollEdgeAppearance = atRest
    }
}
