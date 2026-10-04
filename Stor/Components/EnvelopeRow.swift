import SwiftUI

/// An envelope on the Home card — name, remaining, and a thin bar.
struct EnvelopeSummaryRow: View {
    let envelope: Envelope
    let accent: Color
    @Environment(\.money) private var money

    private var barColor: Color { envelope.isOver ? .storNegative : accent }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            AdaptiveStack(spacing: Spacing.sm) {
                Text(envelope.name)
                    .storText(14)
                    .tracking(-0.07)
                    .foregroundStyle(Color.storInk)
                Spacer(minLength: Spacing.sm)
                MonoText(envelope.rightLabel(money), size: 12, color: barColor)
            }

            ProgressTrack(fraction: envelope.fraction, fill: barColor)
        }
        .padding(.bottom, 14)
    }
}

/// The fuller envelope row on the Budget screen — adds the detail and pace line,
/// and tints its background when expanded.
struct EnvelopeDetailRow: View {
    let envelope: Envelope
    let accent: Color
    let soft: Color
    let isExpanded: Bool
    let isFirst: Bool
    var action: () -> Void

    @Environment(\.money) private var money

    private var barColor: Color { envelope.isOver ? .storNegative : accent }

    /// Expanding a row swaps in the three-month average alongside the detail.
    private var detailLine: String {
        guard isExpanded else { return envelope.detail }
        return "\(envelope.detail) · avg 3mo \(money(envelope.threeMonthAverage))"
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                AdaptiveStack(spacing: Spacing.sm) {
                    Text(envelope.name)
                        .storText(14.5)
                        .tracking(-0.116)
                        .foregroundStyle(Color.storInk)
                    Spacer(minLength: Spacing.sm)
                    MonoText(envelope.rightLabel(money), size: 12.5, color: barColor)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.storSecondaryLabel)
                }
                .padding(.bottom, Spacing.sm)

                ProgressTrack(fraction: envelope.fraction, height: TrackHeight.row, fill: barColor)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    MonoText(detailLine, size: 13, color: .storQuaternaryLabel)
                    MonoText(envelope.pace, size: 10.5, color: .storQuaternaryLabel)
                }
                .padding(.top, Spacing.xs)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isExpanded ? soft : Color.storSurface)
            .overlay(alignment: .top) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.storHairline)
                        .frame(height: Stroke.hairline)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityHint("Shows or hides the three-month average")
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}
