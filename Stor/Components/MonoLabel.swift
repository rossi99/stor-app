import SwiftUI

/// The uppercase, widely tracked SF Mono micro-label that heads almost every
/// block in this design. Size drives the tracking, so the optical spacing holds
/// whether it is a 9.5pt card header or a 10.5pt screen kicker.
struct MonoLabel: View {
    let text: String
    var size: CGFloat = 10
    var tracking: CGFloat = 0.13
    var color: Color = .storTertiaryLabel

    init(_ text: String,
         size: CGFloat = 10,
         tracking: CGFloat = 0.13,
         color: Color = .storTertiaryLabel) {
        self.text = text
        self.size = size
        self.tracking = tracking
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(.mono(size))
            .tracking(tracking * size)
            .foregroundStyle(color)
    }
}

/// Mono text that keeps its casing — money, dates, metadata under a row title.
struct MonoText: View {
    let text: String
    var size: CGFloat = 12
    var color: Color = .storInk

    init(_ text: String, size: CGFloat = 12, color: Color = .storInk) {
        self.text = text
        self.size = size
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.mono(size))
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MonoLabel("August recap")
        MonoLabel("Step 1 of 3", size: 10.5, tracking: 0.14)
        MonoText("£3,410.00")
    }
    .padding()
    .background(Color.storBackground)
}
