import SwiftUI

/// The net-worth line and its filled area. Values are normalised against their
/// own min and max, so every range fills the frame regardless of scale.
struct Sparkline: View {
    let values: [Double]
    var lineColor: Color = .storAccent
    var areaColor: Color = .storAccentSoft
    var lineWidth: CGFloat = 2
    /// Headroom above the peak so the stroke isn't clipped at the top.
    private let topInset: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let points = points(in: geo.size)

            ZStack {
                area(points, height: geo.size.height).fill(areaColor)

                line(points).stroke(
                    lineColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .frame(height: 96)
    }

    private func points(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else {
            return [CGPoint(x: 0, y: size.height / 2)]
        }

        let lowest = values.min() ?? 0
        let highest = values.max() ?? 0
        let span = highest - lowest
        let usable = size.height - topInset - lineWidth

        return values.enumerated().map { index, value in
            let x = CGFloat(index) / CGFloat(values.count - 1) * size.width
            // A flat series sits on the baseline rather than dividing by zero.
            let normalised = span > 0 ? (value - lowest) / span : 0
            let y = topInset + usable * (1 - normalised)
            return CGPoint(x: x, y: y)
        }
    }

    private func line(_ points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
        }
    }

    private func area(_ points: [CGPoint], height: CGFloat) -> Path {
        Path { path in
            guard let first = points.first, let last = points.last else { return }
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
            path.addLine(to: CGPoint(x: last.x, y: height))
            path.addLine(to: CGPoint(x: first.x, y: height))
            path.closeSubpath()
        }
    }
}

#Preview {
    Sparkline(values: [219.4, 221, 222.3, 223.1, 224.8, 226, 227.2, 228.1, 229.4, 230, 231.2, 233.94])
        .padding()
        .background(Color.storSurface)
}
