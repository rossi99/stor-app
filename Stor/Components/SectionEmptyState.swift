import SwiftUI

struct SectionEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let buttonLabel: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.subheadline.weight(.semibold))

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Label(buttonLabel, systemImage: "plus")
                    .font(.caption.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .tint(.storAccent)
            .controlSize(.small)
            .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(Spacing.lg)
        .storCard()
    }
}

#Preview {
    SectionEmptyState(
        icon: "building.columns",
        title: "No pensions yet",
        message: "Add a pension to start tracking progress toward retirement.",
        buttonLabel: "Add pension",
        action: {}
    )
    .padding()
    .background(Color.storBackground)
}
