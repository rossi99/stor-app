import SwiftUI

struct SavingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.md) {

                    PageHeader(title: "Savings")
                        .padding(.horizontal, Spacing.md)

                    FinancialPositionCard(position: appState.financialPosition)
                        .padding(.horizontal, Spacing.md)

                    SectionHeader(title: "Pensions")
                        .padding(.horizontal, Spacing.md)

                    ForEach(appState.pensions) { pension in
                        PensionCard(pension: pension)
                            .padding(.horizontal, Spacing.md)
                    }

                    SectionHeader(title: "Savings pots")
                        .padding(.horizontal, Spacing.md)

                    ForEach(appState.savingsPots) { pot in
                        SavingsPotCard(pot: pot)
                            .padding(.horizontal, Spacing.md)
                    }

                    SectionHeader(title: "ISAs")
                        .padding(.horizontal, Spacing.md)

                    ForEach(appState.isas) { isa in
                        ISACard(isa: isa)
                            .padding(.horizontal, Spacing.md)
                    }
                }
                .padding(.vertical, Spacing.md)
            }
            .background(Color.storBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    SavingsView()
        .environment(AppState())
}

#Preview("Dark") {
    SavingsView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
