import SwiftUI

struct ProgressBar: View {
    let value: Double
    var color: Color = .storAccent
    var trackColor: Color = .progressTrack
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(trackColor)
                    .frame(height: height)
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(color)
                    .frame(width: max(geo.size.width * CGFloat(min(value, 1.0)), 0), height: height)
                    .animation(.easeInOut(duration: 0.4), value: value)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 12) {
        ProgressBar(value: 0.67)
        ProgressBar(value: 0.33, color: .storWarning)
        ProgressBar(value: 1.0,  color: .storSuccess)
    }
    .padding()
}
