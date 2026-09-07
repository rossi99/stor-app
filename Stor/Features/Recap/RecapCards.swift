import SwiftUI

/// Where the month went. Bars are scaled against the largest category, not the
/// total, so the smaller envelopes stay readable.
struct RecapCategoriesCard: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel("Where it went · tap a row")
                .padding(.bottom, 14)

            ForEach(appState.recap.categories) { category in
                row(category)
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 17)
        .padding(.bottom, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard(radius: Radius.xl)
    }

    private func row(_ category: RecapCategory) -> some View {
        let isOpen = appState.expandedCategory == category.name
        let peak = appState.recap.largestCategory

        return Button {
            appState.toggleExpanded(category.name)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(category.name)
                        .font(.text(13.5))
                        .tracking(-0.0675)
                        .foregroundStyle(isOpen ? Color.storAccent : Color.storInk)

                    Spacer(minLength: Spacing.sm)

                    MonoText(deltaLabel(category), size: 11, color: deltaColor(category))
                    MonoText(money(category.amount), size: 12.5)
                        .padding(.leading, Spacing.sm)
                }
                .padding(.bottom, 5)

                ProgressTrack(
                    fraction: peak > 0 ? category.amount / peak : 0,
                    height: TrackHeight.recap,
                    fill: isOpen ? Color.storAccent : Color.storAccent.opacity(0.42),
                    track: .storInk.opacity(0.06)
                )

                if isOpen {
                    Text(detail(category))
                        .font(.text(12))
                        .lineSpacing(2)
                        .foregroundStyle(Color.storSecondaryLabel)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 9)
                        .padding(.bottom, 2)
                }
            }
            .padding(.bottom, Spacing.md)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isOpen)
    }

    private func deltaLabel(_ category: RecapCategory) -> String {
        category.isFixed ? "—" : money.signed(category.delta)
    }

    private func deltaColor(_ category: RecapCategory) -> Color {
        if category.delta > 0 { return .storNegative }
        if category.delta < 0 { return .storPositive }
        return .storChevron
    }

    private func detail(_ category: RecapCategory) -> String {
        guard !category.isFixed else {
            return "Fixed commitment — no month-on-month movement."
        }
        let direction = category.delta > 0 ? "Up" : "Down"
        return "\(direction) \(money(abs(category.delta))) on the previous month. Paid from the joint pot."
    }
}

/// Expected net against what actually landed. The kind of thing a spend tracker
/// never catches.
struct PayslipCheckCard: View {
    @Environment(\.money) private var money

    private var toReview: Int {
        MockData.payslips.filter { !$0.isAsExpected }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                MonoLabel("Payslip check")
                Spacer(minLength: Spacing.sm)
                if toReview > 0 {
                    MonoLabel("\(toReview) to review", size: 10, tracking: 0.06,
                              color: .storNegative)
                }
            }
            .padding(.bottom, Spacing.xs)

            Text("Expected net = gross − income tax − National Insurance, against what actually landed.")
                .font(.text(12.5))
                .lineSpacing(2)
                .foregroundStyle(Color.storSecondaryLabel)
                .padding(.bottom, 14)

            ForEach(MockData.payslips) { payslip in
                row(payslip)
            }
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard(radius: Radius.xl)
    }

    private func row(_ payslip: Payslip) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RowSeparator(isVisible: true)
                .padding(.bottom, 13)

            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: Spacing.sm) {
                    Circle().fill(payslip.ledger.accent).frame(width: 8, height: 8)
                    Text(payslip.name)
                        .font(.text(14.5, weight: .semibold))
                        .tracking(-0.116)
                        .foregroundStyle(Color.storInk)
                }

                Spacer(minLength: Spacing.sm)

                MonoText(flagLabel(payslip), size: 11,
                         color: payslip.isAsExpected ? .storAccent : .storNegative)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(payslip.isAsExpected ? Color.storAccentSoft : Color.storNegativeSoft)
                    .clipShape(.rect(cornerRadius: Radius.xs - 1, style: .continuous))
            }
            .padding(.bottom, Spacing.sm + 2)

            HStack(alignment: .top, spacing: 0) {
                figure("Gross", money(payslip.gross))
                figure("Tax", money(payslip.tax, decimals: 2))
                figure("NI", money(payslip.nationalInsurance, decimals: 2))
                figure("Received", money(payslip.received, decimals: 2),
                       color: payslip.isAsExpected ? .storInk : .storNegative,
                       alignment: .trailing)
            }

            Text(payslip.note)
                .font(.text(12))
                .lineSpacing(2)
                .foregroundStyle(Color.storSecondaryLabel)
                .padding(.top, Spacing.sm + 2)
                .padding(.bottom, 3)
        }
    }

    private func flagLabel(_ payslip: Payslip) -> String {
        payslip.isAsExpected ? "As expected" : "\(money(payslip.shortfall, decimals: 2)) short"
    }

    private func figure(_ label: String, _ value: String,
                        color: Color = .storInk,
                        alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: alignment, spacing: Spacing.xxs) {
            MonoLabel(label, size: 9.5, tracking: 0.1, color: .storQuaternaryLabel)
            MonoText(value, size: 12.5, color: color)
        }
        .frame(maxWidth: .infinity,
               alignment: alignment == .trailing ? .trailing : .leading)
    }
}
