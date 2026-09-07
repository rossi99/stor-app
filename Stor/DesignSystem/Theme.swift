import SwiftUI

enum Spacing {
    static let xxs: CGFloat =  4
    static let xs:  CGFloat =  6
    static let sm:  CGFloat =  8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 26

    /// Horizontal inset every screen's content sits within.
    static let screen: CGFloat = 20
}

enum Radius {
    static let xs:   CGFloat =  9
    static let sm:   CGFloat = 11
    static let md:   CGFloat = 14
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 18
    static let xxl:  CGFloat = 20
    static let sheet: CGFloat = 26
    static let pill:  CGFloat = 999
}

enum Stroke {
    static let hairline: CGFloat = 1
}

/// Bar heights used by progress tracks, sized by how much weight the row carries.
enum TrackHeight {
    static let thin:   CGFloat = 4
    static let row:    CGFloat = 5
    static let hero:   CGFloat = 6
    static let recap:  CGFloat = 7
    static let goal:   CGFloat = 8
}
