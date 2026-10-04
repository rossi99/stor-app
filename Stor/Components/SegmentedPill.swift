import SwiftUI

/// The ledger toggle — the spine of the app. A tinted trough with a white,
/// softly shadowed thumb on the active segment.
struct SegmentedPill<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    var height: CGFloat = 34
    var label: (Value) -> String
    /// An optional identity dot ahead of the label.
    var dot: (Value) -> Color? = { _ in nil }

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(options, id: \.self) { option in
                let isOn = option == selection

                Button {
                    selection = option
                } label: {
                    HStack(spacing: Spacing.xs) {
                        if let dot = dot(option) {
                            Circle().fill(dot).frame(width: 7, height: 7)
                        }
                        Text(label(option))
                            .storText(13, weight: isOn ? .semibold : .medium)
                            .tracking(-0.065)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: max(44, height))
                    .foregroundStyle(isOn ? Color.storInk : Color.storSecondaryLabel)
                    .background {
                        if isOn {
                            RoundedRectangle(cornerRadius: Radius.xs + 1, style: .continuous)
                                .fill(Color.storSurface)
                                .shadow(color: .black.opacity(0.10), radius: 1, y: 1)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
        .padding(Spacing.xxs)
        .background(Color.storFill)
        .clipShape(.rect(cornerRadius: Radius.md - 1, style: .continuous))
    }
}

/// A horizontal row of filter chips — dark when active, outlined when not.
struct ChipRow<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    var label: (Value) -> String

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.xs + 1) {
                ForEach(options, id: \.self) { option in
                    let isOn = option == selection

                    Button {
                        selection = option
                    } label: {
                        Text(label(option))
                            .storText(12.5, weight: isOn ? .semibold : .medium)
                            .foregroundStyle(isOn ? Color.storBackground : Color.storBodyInk)
                            .padding(.horizontal, 13)
                            .frame(minHeight: 44)
                            .background(isOn ? Color.storInk : Color.storSurface)
                            .clipShape(.capsule)
                            .overlay {
                                Capsule().strokeBorder(
                                    isOn ? Color.storInk : Color.storInk.opacity(0.12),
                                    lineWidth: Stroke.hairline
                                )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isOn ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, Spacing.screen)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}
