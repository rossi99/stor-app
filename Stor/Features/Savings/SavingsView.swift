import SwiftUI

struct SavingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddPension = false
    @State private var showAddSavingsPot = false
    @State private var showAddISA = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.xl) {

                    PageHeader(title: "Savings")
                        .padding(.horizontal, Spacing.md)

                    FinancialPositionCard(position: appState.financialPosition)
                        .padding(.horizontal, Spacing.md)

                    VStack(spacing: Spacing.md) {
                        SectionHeader(title: "Pensions", action: { showAddPension = true }, actionLabel: "Add")
                            .padding(.horizontal, Spacing.md)

                        if appState.pensions.isEmpty {
                            SectionEmptyState(
                                icon: "building.columns",
                                title: "No pensions yet",
                                message: "Add a pension to start tracking progress toward retirement.",
                                buttonLabel: "Add pension",
                                action: { showAddPension = true }
                            )
                            .padding(.horizontal, Spacing.md)
                        } else {
                            ForEach(appState.pensions) { pension in
                                PensionCard(pension: pension)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }

                    VStack(spacing: Spacing.md) {
                        SectionHeader(title: "Savings pots", action: { showAddSavingsPot = true }, actionLabel: "Add")
                            .padding(.horizontal, Spacing.md)

                        if appState.savingsPots.isEmpty {
                            SectionEmptyState(
                                icon: "banknote",
                                title: "No savings pots yet",
                                message: "Create a pot to start saving toward a goal.",
                                buttonLabel: "Add savings pot",
                                action: { showAddSavingsPot = true }
                            )
                            .padding(.horizontal, Spacing.md)
                        } else {
                            ForEach(appState.savingsPots) { pot in
                                SavingsPotCard(pot: pot)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }

                    VStack(spacing: Spacing.md) {
                        SectionHeader(title: "ISAs", action: { showAddISA = true }, actionLabel: "Add")
                            .padding(.horizontal, Spacing.md)

                        if appState.isas.isEmpty {
                            SectionEmptyState(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "No ISAs yet",
                                message: "Add an ISA to track your tax-free allowance and balance.",
                                buttonLabel: "Add ISA",
                                action: { showAddISA = true }
                            )
                            .padding(.horizontal, Spacing.md)
                        } else {
                            ForEach(appState.isas) { isa in
                                ISACard(isa: isa)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }
                }
                .padding(.vertical, Spacing.md)
            }
            .background(Color.storBackground)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddPension) { AddPensionView() }
            .sheet(isPresented: $showAddSavingsPot) { AddSavingsPotView() }
            .sheet(isPresented: $showAddISA) { AddISAView() }
        }
        .statusBarGradient()
    }
}

#Preview {
    SavingsView()
        .environment(AppState())
}
