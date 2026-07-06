import SwiftUI

struct AllocationRow: View {
    let label: String
    let expectedAmount: Double
    let actualAmount: Double
    let color: Color
    /// Budget carried in from the previous bucket: positive = inherited extra,
    /// negative = surrendered to cover an earlier overspend.
    var carryOver: Double = 0
    /// Amount leaving this bucket into the next one. When nil this is the last
    /// bucket and the remainder is labelled as surplus instead.
    var carryForward: Double? = nil
    /// Name of the next bucket (e.g. "Wants"). Nil for the savings row.
    var nextBucketLabel: String? = nil

    private var actualFraction: Double {
        guard expectedAmount > 0 else { return actualAmount > 0 ? 1 : 0 }
        return min(actualAmount / expectedAmount, 1)
    }
    private var isOver: Bool { actualAmount > expectedAmount }

    /// Share of this bucket's budget made up by carried-over budget.
    private var carryFraction: Double {
        guard expectedAmount > 0 else { return 0 }
        return min(abs(carryOver) / expectedAmount, 1)
    }
    private var hasPositiveSurplus: Bool { carryOver >= 1 }
    private var hasNegativeSurplus: Bool { carryOver <= -1 }

    /// Fraction of the bar the surplus occupies at the trailing end; the track
    /// shrinks by this amount to reveal it.
    private var surplusFraction: CGFloat {
        (hasPositiveSurplus || hasNegativeSurplus) ? CGFloat(carryFraction) : 0
    }

    private let barHeight: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                (Text(actualAmount.gbpRounded)
                    .foregroundStyle(isOver ? Color.storNegative : Color.storPositive)
                    .fontWeight(.semibold)
                 + Text(" of \(expectedAmount.gbpRounded)")
                    .foregroundStyle(.secondary))
                .font(.storTabular(.subheadline))
            }

            GeometryReader { geo in
                let w = geo.size.width
                let trackWidth = w * (1 - surplusFraction)
                // Extend the surplus 5% further left so it tucks behind the
                // track, closing the gap between their rounded caps.
                let overlap = w * 0.05
                let surplusWidth = w * surplusFraction + overlap
                let surplusOffset = trackWidth - overlap
                ZStack(alignment: .leading) {
                    // back — surpluses, right-aligned, revealed as the track shrinks
                    if hasPositiveSurplus {
                        AllocationSurplusShape()
                            .fill(Color.storPositive.opacity(0.55))
                            .frame(width: surplusWidth)
                            .offset(x: surplusOffset)
                    }
                    if hasNegativeSurplus {
                        AllocationSurplusShape()
                            .fill(Color.storNegative.opacity(0.55))
                            .frame(width: surplusWidth)
                            .offset(x: surplusOffset)
                    }

                    // middle — the progress bar (track)
                    AllocationTrackShape()
                        .fill(Color.progressTrack)
                        .frame(width: trackWidth)

                    // front — the progress, a fraction of the (shrunken) track
                    AllocationFillShape()
                        .fill(isOver ? Color.storNegative : color)
                        .frame(width: trackWidth * CGFloat(actualFraction))
                }
                .frame(width: w, height: barHeight, alignment: .leading)
                .animation(.easeInOut(duration: 0.4), value: actualFraction)
                .animation(.easeInOut(duration: 0.4), value: surplusFraction)
            }
            .frame(height: barHeight)

            if let forward = carryForward, abs(forward) >= 1 {
                let isPositive = forward >= 0
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(isPositive ? Color.storPositive : Color.storNegative)
                    if let next = nextBucketLabel {
                        (Text(isPositive ? "+" : "")
                         + Text(forward.gbpRounded)
                         + Text(" to \(next)"))
                        .font(.storTabular(.caption2))
                        .foregroundStyle(isPositive ? Color.storPositive : Color.storNegative)
                    } else {
                        (Text(isPositive ? "+" : "")
                         + Text(forward.gbpRounded)
                         + Text(isPositive ? " surplus remaining" : " deficit"))
                        .font(.storTabular(.caption2))
                        .foregroundStyle(isPositive ? Color.storPositive : Color.storNegative)
                    }
                    Spacer()
                }
            }
        }
    }
}

/// The progress bar's full-width track: a capsule filling its frame.
struct AllocationTrackShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: rect.height / 2, style: .circular)
    }
}

/// The progress: a convex-capped pill filling its frame (width set by the
/// caller to the used fraction of the track).
struct AllocationFillShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: rect.height / 2, style: .circular)
    }
}

/// A surplus slice — positive or negative — a capsule filling its frame, which
/// the caller positions at the trailing end of the bar.
struct AllocationSurplusShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: rect.height / 2, style: .circular)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        AllocationRow(label: "Needs",   expectedAmount: 2825, actualAmount: 3475, color: .blue)
        AllocationRow(label: "Wants",   expectedAmount: 1823, actualAmount:  945, color: .purple, carryOver: 128)
        AllocationRow(label: "Savings", expectedAmount: 1130, actualAmount: 1133, color: .storAccent, carryOver: -50)
    }
    .padding()
}
