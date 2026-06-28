import SwiftUI

struct PensionCard: View {
    let pension: Pension

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Text("🏦")
                        Text("Pension · \(pension.memberName.components(separatedBy: " ").first ?? pension.memberName)")
                            .font(.subheadline.weight(.semibold))
                    }
                    Text("Last updated \(pension.lastUpdated.dayMonthYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {} label: {
                    Label("Update", systemImage: "pencil")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(pension.currentValue.gbpRounded)
                        .font(.storDisplay(.title2))
                    Text(" of \(pension.target.gbpRounded)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ProgressBar(value: pension.progress, color: .storAccent)
                Text(pension.progress.percent + " to target")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ForEach(MockData.pensions) { p in
            PensionCard(pension: p)
        }
    }
    .padding()
    .background(Color.storBackground)
}

#Preview("Dark") {
    VStack(spacing: Spacing.md) {
        ForEach(MockData.pensions) { p in
            PensionCard(pension: p)
        }
    }
    .padding()
    .background(Color.storBackground)
    .preferredColorScheme(.dark)
}
