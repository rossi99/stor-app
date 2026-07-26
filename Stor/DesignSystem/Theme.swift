import SwiftUI

enum Spacing {
    static let xs: CGFloat  =  4
    static let sm: CGFloat  =  8
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 24
    static let xl: CGFloat  = 32
    static let xxl: CGFloat = 48
}

enum Radius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
}

// Brand/surface/text/progress colors are asset-catalog color sets in
// Assets.xcassets. The app is light-only (see `.preferredColorScheme(.light)`
// in StorApp.swift), so each set has a single universal appearance. Xcode
// auto-generates `Color.storX` / `ShapeStyle.storX` accessors for each color
// set (GeneratedAssetSymbols.swift), so those names must NOT be redeclared
// here — only the two money colors that have no asset entry.
extension Color {
    static let storPositive = Color(red: 0.180, green: 0.490, blue: 0.275)  // #2E7D46
    static let storSuccess  = Color(red: 0.180, green: 0.490, blue: 0.275)  // #2E7D46
    static let storNegative = Color(red: 0.706, green: 0.278, blue: 0.180)  // #B4472E
}

extension View {
    /// Adds a gradient fade from `storBackground` over the status-bar safe area,
    /// preventing scroll content from bleeding visually behind the clock/battery.
    func statusBarGradient(_ active: Bool = true) -> some View {
        overlay(alignment: .top) {
            if active {
                LinearGradient(
                    colors: [Color.storBackground, Color.storBackground.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
            }
        }
    }
}

// Allows `.storX` in ShapeStyle contexts (foregroundStyle, fill, tint, etc.)
// for the money colors only — every asset-backed color already gets this via
// Xcode's generated `ShapeStyle where Self == Color` extension.
extension ShapeStyle where Self == Color {
    static var storPositive: Color { Color.storPositive }
    static var storSuccess:  Color { Color.storSuccess }
    static var storNegative: Color { Color.storNegative }
}
