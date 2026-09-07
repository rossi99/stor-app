import SwiftUI

struct AlertsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "Alerts") { dismiss() }

            ScrollView {
                VStack(spacing: Spacing.sm + 2) {
                    ForEach(MockData.alerts) { alert in
                        card(alert)
                    }
                }
                .screenInset()
                .padding(.top, Spacing.xxs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func card(_ alert: AlertItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(alert.tone == .attention ? Color.storNegative : Color.storAccent)
                    .frame(width: 7, height: 7)

                MonoLabel(alert.kind.rawValue, size: 9.5, tracking: 0.12)

                Spacer(minLength: Spacing.sm)

                MonoText(alert.when, size: 10, color: .storQuaternaryLabel)
            }
            .padding(.bottom, Spacing.sm)

            Text(alert.title)
                .font(.text(15, weight: .semibold))
                .tracking(-0.15)
                .foregroundStyle(Color.storInk)
                .padding(.bottom, 5)

            Text(alert.body)
                .font(.text(13))
                .lineSpacing(3)
                .foregroundStyle(Color.storSecondaryLabel)
                .multilineTextAlignment(.leading)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alert.isHighlighted ? Color.storAccentSoft : Color.storSurface)
        .clipShape(.rect(cornerRadius: Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(
                    alert.isHighlighted ? Color.storAccent.opacity(0.14) : Color.storBorder,
                    lineWidth: Stroke.hairline
                )
        }
    }
}

#Preview {
    AlertsView().environment(AppState())
}
