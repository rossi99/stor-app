import SwiftUI

/// A bordered card wrapping a stack of rows separated by hairlines. Rows supply
/// their own padding; the card only owns the border and the clipping.
struct RowCard<Content: View>: View {
    var radius: CGFloat = Radius.lg
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .frame(maxWidth: .infinity)
            .storCard(radius: radius)
    }
}

/// A hairline divider drawn above a row when it isn't the first in its card.
struct RowSeparator: View {
    let isVisible: Bool

    var body: some View {
        Rectangle()
            .fill(isVisible ? Color.storHairline : .clear)
            .frame(height: Stroke.hairline)
    }
}

/// A padded card with a mono header and free-form content beneath it.
struct LabelledCard<Content: View>: View {
    let label: String
    var trailingText: String?
    var actionTitle: String?
    var action: (() -> Void)?
    var radius: CGFloat = Radius.lg
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardHeader(label: label, trailingText: trailingText,
                       actionTitle: actionTitle, action: action)
                .padding(.bottom, 14)
            content
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard(radius: radius)
    }
}

/// Keep amounts and labels readable when people choose accessibility text sizes.
struct AdaptiveStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    var spacing: CGFloat = Spacing.md
    @ViewBuilder var content: Content

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(alignment: .center, spacing: spacing))
        layout { content }
    }
}
