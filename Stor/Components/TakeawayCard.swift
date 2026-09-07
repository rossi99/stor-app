import SwiftUI

/// The lime "one thing" card — the single observation worth acting on.
struct TakeawayCard: View {
    let label: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            MonoLabel(label, size: 10, color: .storLimeLabel)
            Text(text)
                .font(.text(15.5))
                .tracking(-0.124)
                .lineSpacing(3)
                .foregroundStyle(Color.storLimeInk)
        }
        .padding(Spacing.lg + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storSolidCard(radius: Radius.xl, fill: .storLime)
    }
}

/// A soft accent panel — used for the emergency-fund summary.
struct AccentPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(Spacing.lg + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .storSolidCard(radius: Radius.xl, fill: .storAccentSoft)
    }
}
