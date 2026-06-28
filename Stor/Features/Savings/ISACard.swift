import SwiftUI

struct ISACard: View {
    let isa: ISA

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Text("📈")
                        Text("\(isa.type)")
                            .font(.subheadline.weight(.semibold))
                    }
                    Text(isa.memberName.components(separatedBy: " ").first ?? isa.memberName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(isa.balance.gbpRounded)
                        .font(.storDisplay(.title2))
                    Text("balance")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text("This tax year")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(isa.contributionsThisYear.gbpRounded) of \(isa.annualAllowance.gbpRounded)")
                        .font(.storTabular(.caption, weight: .medium))
                }
                ProgressBar(value: isa.allowanceUsedFraction, color: .storAccent)
                HStack {
                    Text(isa.allowanceUsedFraction.percent + " allowance used")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(isa.remainingAllowance.gbpRounded + " remaining")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ForEach(MockData.isas) { isa in
            ISACard(isa: isa)
        }
    }
    .padding()
    .background(Color.storBackground)
}
