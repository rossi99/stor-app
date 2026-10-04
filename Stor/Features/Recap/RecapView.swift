import SwiftUI

/// A finished month: what was spent, where it went, whether the payslips were
/// right, and the one thing worth doing about it.
struct RecapView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "Monthly recap") { dismiss() }

            ScrollView {
                VStack(spacing: Spacing.md) {
                    monthPicker
                    summaryCard
                    RecapCategoriesCard()

                    if appState.showPayslipCheck {
                        PayslipCheckCard()
                    }

                    TakeawayCard(label: "One thing", text: appState.recap.takeaway)
                }
                .screenInset()
                .padding(.top, Spacing.xxs)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.storBackground)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var monthPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(MockData.recaps) { recap in
                let isOn = appState.recapMonth == recap.month

                Button {
                    appState.recapMonth = recap.month
                    appState.expandedCategory = nil
                } label: {
                    Text(recap.id)
                        .storText(12.5, weight: isOn ? .semibold : .medium)
                        .foregroundStyle(isOn ? Color.storBackground : Color.storSecondaryLabel)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(isOn ? Color.storInk : Color.storSurface)
                        .clipShape(.rect(cornerRadius: Radius.xs + 1, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
    }

    private var summaryCard: some View {
        let recap = appState.recap

        return VStack(alignment: .leading, spacing: 0) {
            MonoLabel("\(recap.id) · household spend", size: 10,
                      color: .storBackground.opacity(0.6))

            Text(money(recap.total))
                .storDisplay(46)
                .tracking(-0.92)
                .foregroundStyle(Color.storBackground)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xs)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(varianceLine(recap))
                .storText(13.5)
                .lineSpacing(2)
                .foregroundStyle(Color.storBackground.opacity(0.72))

            Rectangle()
                .fill(Color.storBackground.opacity(0.18))
                .frame(height: Stroke.hairline)
                .padding(.top, Spacing.lg + 2)
                .padding(.bottom, Spacing.lg)

            HStack(alignment: .top, spacing: 22) {
                figure("Received", money(recap.income))
                figure("Saved", money(recap.saved))
                figure("Rate", "\(recap.savingsRate)%")
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storSolidCard(radius: Radius.xl, fill: .storAccent)
    }

    private func figure(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            MonoLabel(label, size: 9.5, tracking: 0.12, color: .storBackground.opacity(0.6))
            MonoText(value, size: 15, color: .storBackground)
        }
    }

    private func varianceLine(_ recap: MonthRecap) -> String {
        let variance = money(recap.variance)
        let plan = money(recap.budget)
        return recap.isOverBudget
            ? "\(variance) over the \(plan) plan"
            : "\(variance) under the \(plan) plan"
    }
}

#Preview {
    RecapView().environment(AppState())
}
