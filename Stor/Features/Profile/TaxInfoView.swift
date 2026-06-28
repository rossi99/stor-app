import SwiftUI

struct TaxInfoView: View {
    @Environment(AppState.self) private var appState

    private var tax: TaxInfo { appState.taxInfo }

    var body: some View {
        List {
            Section("Income") {
                LabeledContent("Gross monthly", value: tax.grossMonthly.gbp)
                LabeledContent("Gross annual", value: tax.annualGross.gbp)
            }
            .listRowBackground(Color.storSurface)

            Section("Tax") {
                LabeledContent("Tax code",   value: tax.taxCode)
                LabeledContent("Tax system", value: tax.taxSystem)
                LabeledContent("Tax year",   value: tax.taxYear)
                LabeledContent("Marital status", value: tax.maritalStatus)
            }
            .listRowBackground(Color.storSurface)

            Section("Deductions") {
                LabeledContent("Pension contribution", value: "\(Int(tax.pensionContributionPercent))%")
                HStack {
                    Text("Student loan")
                    Spacer()
                    if tax.hasStudentLoan, let plan = tax.studentLoanPlan {
                        Text(plan)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("None")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listRowBackground(Color.storSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.storBackground)
        .navigationTitle("Tax information")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        TaxInfoView()
            .environment(AppState())
    }
}
