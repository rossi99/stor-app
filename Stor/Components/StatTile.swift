import SwiftUI

/// One of the paired tiles under the hero — a label, a figure, a footnote.
struct StatTile: View {
    let label: String
    let value: String
    let footnote: String
    var footnoteColor: Color = .storSecondaryLabel
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                MonoLabel(label)
                    .padding(.bottom, 9)

                Text(value)
                    .font(.display(23))
                    .tracking(-0.23)
                    .foregroundStyle(Color.storInk)

                Text(footnote)
                    .font(.text(12))
                    .foregroundStyle(footnoteColor)
                    .padding(.top, 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
            .padding(.top, 15)
            .padding(.bottom, 14)
            .storCard()
        }
        .buttonStyle(.plain)
    }
}

/// A compact figure tile — the Budgeted / Spent / Left triplet.
struct CompactStat: View {
    let label: String
    let value: String
    var valueColor: Color = .storInk
    var fill: Color = .storSurface

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            MonoLabel(label, size: 9.5, tracking: 0.12)
            MonoText(value, size: 16, color: valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .storCard(radius: Radius.md, fill: fill)
    }
}
