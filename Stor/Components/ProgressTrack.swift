import SwiftUI

/// A rounded progress bar. Every bar in the app is one of these — the only
/// things that change are height, fill and track colour.
struct ProgressTrack: View {
    let fraction: Double
    var height: CGFloat = TrackHeight.thin
    var fill: Color = .storAccent
    var track: Color = .storTrack

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(track)

                Capsule(style: .continuous)
                    .fill(fill)
                    .frame(width: geo.size.width * max(0, min(1, fraction)))
            }
        }
        .frame(height: height)
    }
}

/// The two-tone bar showing how a joint spend is apportioned.
struct SplitTrack: View {
    /// Ana's share, 0...1.
    let fraction: Double
    var height: CGFloat = TrackHeight.goal

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Rectangle().fill(Color.storAna)
                    .frame(width: geo.size.width * max(0, min(1, fraction)))
                Rectangle().fill(Color.storSam)
            }
        }
        .frame(height: height)
        .clipShape(.capsule(style: .continuous))
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressTrack(fraction: 0.42)
        ProgressTrack(fraction: 0.9, height: TrackHeight.goal, fill: .storNegative)
        SplitTrack(fraction: 0.6)
    }
    .padding()
    .background(Color.storBackground)
}
