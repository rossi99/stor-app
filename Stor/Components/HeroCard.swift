import SwiftUI

/// The safe-to-spend hero. Takes the selected ledger's accent as its ground, so
/// switching ledger recolours the top of the screen.
struct HeroCard: View {
    let model: SafeToSpend
    let accent: Color
    let daysLeft: Int
    @Environment(\.money) private var money

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                MonoLabel(model.label, size: 10.5, color: .storBackground.opacity(0.62))
                Spacer(minLength: Spacing.sm)
                MonoLabel("\(daysLeft) days left", size: 10.5, tracking: 0.06,
                          color: .storBackground.opacity(0.62))
            }

            Text(money(model.remaining))
                .font(.display(58))
                .tracking(-1.16)
                .foregroundStyle(Color.storBackground)
                .padding(.top, 14)
                .padding(.bottom, Spacing.xxs)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(model.caption)
                .font(.text(13.5))
                .foregroundStyle(Color.storBackground.opacity(0.72))
                .padding(.bottom, Spacing.xl)

            ProgressTrack(
                fraction: model.fraction,
                height: TrackHeight.hero,
                fill: .storLime,
                track: .storBackground.opacity(0.22)
            )

            HStack {
                MonoText("\(money(model.spent)) spent", size: 11,
                         color: .storBackground.opacity(0.66))
                Spacer()
                MonoText("\(money(model.pot)) in", size: 11,
                         color: .storBackground.opacity(0.66))
            }
            .padding(.top, 9)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storSolidCard(radius: Radius.xxl, fill: accent)
    }
}
