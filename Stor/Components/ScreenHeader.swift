import SwiftUI

/// A large screen title, in SF Pro Display at weight 650.
struct ScreenTitle: View {
    let text: String
    var size: CGFloat = 30

    init(_ text: String, size: CGFloat = 30) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .storDisplay(size)
            .tracking(-0.015 * size)
            .foregroundStyle(Color.storInk)
    }
}

/// Header for a pushed screen — round back button, then the title.
struct BackHeader: View {
    let title: String
    var dismiss: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Button(action: dismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.storInk)
                    .frame(width: 44, height: 44)
                    .background(Color.storSurface)
                    .clipShape(.circle)
                    .overlay { Circle().strokeBorder(Color.storBorder, lineWidth: Stroke.hairline) }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            ScreenTitle(title, size: 26)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .screenInset()
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.md)
    }
}

/// A card header: mono label on the left, an optional action on the right.
struct CardHeader: View {
    let label: String
    var trailingText: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        AdaptiveStack(spacing: Spacing.sm) {
            MonoLabel(label)
            Spacer(minLength: Spacing.sm)

            if let trailingText {
                MonoText(trailingText, size: 11)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .storText(14, weight: .medium)
                    .frame(minWidth: 44, minHeight: 44)
                    .foregroundStyle(Color.storAccent)
                    .buttonStyle(.plain)
            }
        }
    }
}
