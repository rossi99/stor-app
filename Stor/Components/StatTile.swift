import SwiftUI

struct StatTile: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    var footnote: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.4)
            Text(value)
                .font(.storDisplay(.title2))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
            if let footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard()
    }
}

#Preview {
    HStack {
        StatTile(label: "Net Income", value: "£5,650", footnote: "this month")
        StatTile(label: "Surplus", value: "£1,452", valueColor: .storSuccess, footnote: "+£919 unallocated")
    }
    .padding()
    .background(Color.storBackground)
}
