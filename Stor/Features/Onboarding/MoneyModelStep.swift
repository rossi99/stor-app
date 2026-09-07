import SwiftUI

/// Step 1 — this decides the shape of everything else.
struct MoneyModelStep: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeading(lead: "How do you two", trail: "keep your money?", step: 1)

            Text("This decides the shape of everything else. You can change it later.")
                .onboardingBody()
                .frame(maxWidth: 290, alignment: .leading)
                .padding(.bottom, 30)

            VStack(spacing: Spacing.sm + 2) {
                ForEach(MoneyModel.allCases) { model in
                    optionRow(model)
                }
            }
        }
    }

    private func optionRow(_ model: MoneyModel) -> some View {
        let isOn = appState.moneyModel == model

        return Button {
            appState.moneyModel = model
        } label: {
            HStack(alignment: .top, spacing: 13) {
                Circle()
                    .fill(isOn ? Color.storAccent : .clear)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle().strokeBorder(
                            isOn ? Color.storAccent : Color.storQuaternaryLabel,
                            lineWidth: 1.5
                        )
                    }
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.title)
                        .font(.text(15, weight: .semibold))
                        .tracking(-0.15)
                        .foregroundStyle(Color.storInk)
                    Text(model.summary)
                        .font(.text(12.5))
                        .lineSpacing(2)
                        .foregroundStyle(Color.storSecondaryLabel)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
            }
            .padding(Spacing.lg)
            .background(isOn ? Color.storAccentSoft : Color.storSurface)
            .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(
                        isOn ? Color.storAccent.opacity(0.45) : Color.storBorder,
                        lineWidth: Stroke.hairline
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
