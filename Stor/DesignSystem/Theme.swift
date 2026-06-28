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

// Builds a Color that switches between light and dark values at runtime.
private func adaptive(light: Color, dark: Color) -> Color {
    Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
}

extension Color {
    // Brand
    static let storAccent      = adaptive(
        light: Color(red: 0.118, green: 0.302, blue: 0.169),  // #1E4D2B
        dark:  Color(red: 0.357, green: 0.690, blue: 0.471)   // #5BB078
    )
    static let storAccentLight = adaptive(
        light: Color(red: 0.180, green: 0.420, blue: 0.251),  // #2E6B40
        dark:  Color(red: 0.251, green: 0.518, blue: 0.345)
    )
    static let storGold = adaptive(
        light: Color(red: 0.765, green: 0.604, blue: 0.243),  // #C39A3E
        dark:  Color(red: 0.851, green: 0.706, blue: 0.361)   // #D9B45C
    )

    // Surfaces
    static let storBackground = adaptive(
        light: Color(red: 0.965, green: 0.941, blue: 0.894),  // #F6F0E4
        dark:  Color(red: 0.075, green: 0.125, blue: 0.102)   // #13201A
    )
    static let storSurface = adaptive(
        light: Color(red: 0.984, green: 0.973, blue: 0.949),  // #FBF8F2
        dark:  Color(red: 0.110, green: 0.165, blue: 0.133)   // #1C2A22
    )
    static let storBorder = adaptive(
        light: Color(red: 0.894, green: 0.867, blue: 0.800),  // #E4DDCC
        dark:  Color(red: 0.165, green: 0.227, blue: 0.188)   // #2A3A30
    )

    // Text
    static let storLabel = adaptive(
        light: Color(red: 0.102, green: 0.165, blue: 0.122),  // #1A2A1F
        dark:  Color(red: 0.941, green: 0.922, blue: 0.875)   // #F0EBDF
    )
    static let storSecondaryLabel = adaptive(
        light: Color(red: 0.369, green: 0.420, blue: 0.380),  // #5E6B61
        dark:  Color(red: 0.616, green: 0.667, blue: 0.624)   // #9DAA9F
    )

    // Semantic — money
    static let storPositive = Color(red: 0.180, green: 0.490, blue: 0.275)  // #2E7D46
    static let storSuccess  = Color(red: 0.180, green: 0.490, blue: 0.275)  // #2E7D46
    static let storNegative = Color(red: 0.706, green: 0.278, blue: 0.180)  // #B4472E
    static let storWarning  = adaptive(
        light: Color(red: 0.765, green: 0.604, blue: 0.243),  // #C39A3E
        dark:  Color(red: 0.851, green: 0.706, blue: 0.361)   // #D9B45C
    )

    // Progress bars
    static let progressNeeds = adaptive(
        light: Color(red: 0.180, green: 0.420, blue: 0.251),  // #2E6B40
        dark:  Color(red: 0.357, green: 0.690, blue: 0.471)   // #5BB078
    )
    static let progressWants = adaptive(
        light: Color(red: 0.690, green: 0.490, blue: 0.235),  // #B07D3C
        dark:  Color(red: 0.824, green: 0.635, blue: 0.298)   // #D2A24C
    )
    static let progressSavings = adaptive(
        light: Color(red: 0.431, green: 0.545, blue: 0.357),  // #6E8B5B
        dark:  Color(red: 0.608, green: 0.722, blue: 0.518)   // #9BB884
    )
    static let progressTrack   = adaptive(
        light: Color(red: 0.925, green: 0.890, blue: 0.827),  // #ECE3D3
        dark:  Color(red: 0.165, green: 0.227, blue: 0.188)   // #2A3A30
    )
}

// Allows `.storX` in ShapeStyle contexts (foregroundStyle, fill, tint, etc.)
extension ShapeStyle where Self == Color {
    static var storAccent:         Color { Color.storAccent }
    static var storAccentLight:    Color { Color.storAccentLight }
    static var storGold:           Color { Color.storGold }
    static var storBackground:     Color { Color.storBackground }
    static var storSurface:        Color { Color.storSurface }
    static var storBorder:         Color { Color.storBorder }
    static var storLabel:          Color { Color.storLabel }
    static var storSecondaryLabel: Color { Color.storSecondaryLabel }
    static var storPositive:       Color { Color.storPositive }
    static var storSuccess:        Color { Color.storSuccess }
    static var storNegative:       Color { Color.storNegative }
    static var storWarning:        Color { Color.storWarning }
    static var progressNeeds:      Color { Color.progressNeeds }
    static var progressWants:      Color { Color.progressWants }
    static var progressSavings:    Color { Color.progressSavings }
    static var progressTrack:      Color { Color.progressTrack }
}
