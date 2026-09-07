import SwiftUI

/// A monogram tile carrying its ledger's tint.
struct MonogramChip: View {
    let text: String
    let ledger: Ledger
    var size: CGFloat = 34

    var body: some View {
        Text(text)
            .font(.mono(11, weight: .semibold))
            .foregroundStyle(ledger.accent)
            .frame(width: size, height: size)
            .background(ledger.soft)
            .clipShape(.rect(cornerRadius: Radius.xs + 1, style: .continuous))
    }
}

/// A full ledger row — monogram, title and subtitle, amount and settlement tag.
struct TransactionRow: View {
    let transaction: Transaction
    let isFirst: Bool
    @Environment(\.money) private var money

    private var amountColor: Color {
        transaction.isIncome ? .storPositive : .storInk
    }

    var body: some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            HStack(spacing: 13) {
                MonogramChip(text: transaction.monogram, ledger: transaction.ledger)

                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.title)
                        .font(.text(14.5))
                        .tracking(-0.116)
                        .foregroundStyle(Color.storInk)
                        .lineLimit(1)
                    MonoText(transaction.subtitle, size: 11.5, color: .storTertiaryLabel)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 2) {
                    MonoText(money.signed(transaction.amount, decimals: 2),
                             size: 13.5, color: amountColor)
                    MonoLabel(transaction.tag, size: 10.5, tracking: 0.04,
                              color: .storQuaternaryLabel)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
        }
        .background(transaction.isNew ? Color.storAccentSoft : Color.storSurface)
    }
}

/// The condensed "Latest" row on Home — a ledger dot instead of a monogram.
struct CompactTransactionRow: View {
    let transaction: Transaction
    let isFirst: Bool
    @Environment(\.money) private var money

    var body: some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            HStack(spacing: Spacing.md) {
                Circle()
                    .fill(transaction.ledger.accent)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 0) {
                    Text(transaction.title)
                        .font(.text(14))
                        .tracking(-0.07)
                        .foregroundStyle(Color.storInk)
                        .lineLimit(1)
                    MonoText("\(transaction.category) · \(transaction.tag)",
                             size: 11.5, color: .storTertiaryLabel)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                MonoText(money.signed(transaction.amount, decimals: 2), size: 13,
                         color: transaction.isIncome ? .storPositive : .storInk)
            }
            .padding(.vertical, 11)
        }
    }
}
