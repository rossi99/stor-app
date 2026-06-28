import SwiftUI

struct CategoryAmount: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let amount: Double
}

struct CategorySplitView: View {
    let items: [CategoryAmount]
    let total: Double

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(items.sorted { $0.amount > $1.amount }.prefix(5)) { item in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: item.category.systemImage)
                        .font(.caption)
                        .foregroundStyle(Color.storAccent)
                        .frame(width: 20)
                    Text(item.category.rawValue)
                        .font(.subheadline)
                    Spacer()
                    Text(item.amount.gbpRounded)
                        .font(.storTabular(.subheadline, weight: .medium))
                    Text(total > 0 ? (item.amount / total).percentInt : "–")
                        .font(.storTabular(.caption))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
    }
}
