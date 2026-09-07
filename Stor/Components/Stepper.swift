import SwiftUI

/// The −/+ pair used to nudge a contribution or a goal. The plus is filled when
/// it is the encouraged direction, outlined when both directions are equal.
struct CircleStepper: View {
    var size: CGFloat = 36
    var emphasisePlus: Bool = true
    var onDecrement: () -> Void
    var onIncrement: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            button("minus", filled: false, action: onDecrement)
            button("plus", filled: emphasisePlus, action: onIncrement)
        }
    }

    private func button(_ symbol: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size * 0.4, weight: .regular))
                .foregroundStyle(filled ? Color.storBackground : Color.storInk)
                .frame(width: size, height: size)
                .background(filled ? Color.storAccent : .clear)
                .clipShape(.circle)
                .overlay {
                    if !filled {
                        Circle().strokeBorder(Color.storInk.opacity(0.14), lineWidth: Stroke.hairline)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

/// The full-width rounded action button that closes each flow.
struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var fill: Color = .storAccent
    var titleColor: Color = .storBackground
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.text(15.5, weight: .semibold))
                .tracking(-0.155)
                .foregroundStyle(isEnabled ? titleColor : Color.storQuaternaryLabel)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? fill : Color.storInk.opacity(0.08))
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
