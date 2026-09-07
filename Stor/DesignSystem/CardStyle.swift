import SwiftUI

// Cards in this design are defined by a hairline border, not a shadow — the
// only elevated surface in the whole app is the add-spend button.

struct CardModifier: ViewModifier {
    var radius: CGFloat = Radius.lg
    var fill: Color = .storSurface

    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(.rect(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.storBorder, lineWidth: Stroke.hairline)
            }
    }
}

/// A card with no border — used where the fill itself carries the meaning
/// (the accent hero, the lime takeaway, the soft emergency-fund panel).
struct SolidCardModifier: ViewModifier {
    var radius: CGFloat = Radius.lg
    var fill: Color

    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(.rect(cornerRadius: radius, style: .continuous))
    }
}

extension View {
    func storCard(radius: CGFloat = Radius.lg, fill: Color = .storSurface) -> some View {
        modifier(CardModifier(radius: radius, fill: fill))
    }

    func storSolidCard(radius: CGFloat = Radius.lg, fill: Color) -> some View {
        modifier(SolidCardModifier(radius: radius, fill: fill))
    }

    /// Standard screen gutter.
    func screenInset() -> some View {
        padding(.horizontal, Spacing.screen)
    }
}
