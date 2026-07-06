import SwiftUI
import Charts

struct ForecastView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    /// When presented as a sheet (e.g. from the dashboard) the view shows a
    /// "Done" button; as a top-level tab it shows the profile button instead.
    var isPresentedAsSheet: Bool = false

    @State private var additionalExpense: Double = 0
    @State private var savingsAdjustment: Double = 0
    @State private var selectedPotID: UUID?

    init(isPresentedAsSheet: Bool = false) {
        self.isPresentedAsSheet = isPresentedAsSheet
    }

    private var selectedPot: SavingsPot? {
        guard let id = selectedPotID else { return appState.savingsPots.first }
        return appState.savingsPots.first { $0.id == id }
    }

    private var baseSurplus: Double     { appState.financialPosition.netSurplus }
    private var adjustedSurplus: Double { baseSurplus - additionalExpense - savingsAdjustment }

    private var pot: SavingsPot? { selectedPot }

    private var baseContribution: Double   { pot?.monthlyContribution ?? 0 }
    private var adjustedContribution: Double { baseContribution + savingsAdjustment }

    private var baseTTG: TimeToGoalResult? {
        guard let p = pot else { return nil }
        return timeToGoal(current: p.current, target: p.target, monthlyContribution: baseContribution)
    }

    private var adjustedTTG: TimeToGoalResult? {
        guard let p = pot, adjustedContribution > 0 else { return nil }
        return timeToGoal(current: p.current, target: p.target, monthlyContribution: max(adjustedContribution, 1))
    }

    private var projectionMonths = 24
    private var baseProjection: [(month: Int, balance: Double)] {
        guard let p = pot else { return [] }
        return projectedBalances(current: p.current, monthlyContribution: baseContribution, months: projectionMonths)
    }
    private var adjustedProjection: [(month: Int, balance: Double)] {
        guard let p = pot else { return [] }
        return projectedBalances(current: p.current, monthlyContribution: max(adjustedContribution, 0), months: projectionMonths)
    }

    private var isModified: Bool {
        additionalExpense != 0 || savingsAdjustment != 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {

                    if !isPresentedAsSheet {
                        PageHeader(title: "Forecast")
                    }

                    surplusComparisonCard
                    inputsCard
                    if let pot {
                        projectionCard(pot: pot)
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.storBackground)
            .navigationTitle(isPresentedAsSheet ? "Forecast" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(isPresentedAsSheet ? .visible : .hidden, for: .navigationBar)
            .toolbar {
                if isPresentedAsSheet {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
        .statusBarGradient(!isPresentedAsSheet)
    }

    private var surplusComparisonCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Monthly surplus")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.4)

            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Before")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(baseSurplus.gbpRounded)
                        .font(.storDisplay(.title2))
                }

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("After")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(adjustedSurplus.gbpRounded)
                        .font(.storDisplay(.title2))
                        .foregroundStyle(adjustedSurplus < 0 ? .storNegative : (isModified ? .storAccent : .primary))
                }

                Spacer()

                if isModified {
                    let delta = adjustedSurplus - baseSurplus
                    Text((delta >= 0 ? "+" : "") + delta.gbpRounded)
                        .font(.storTabular(.subheadline, weight: .semibold))
                        .foregroundStyle(delta >= 0 ? .storSuccess : .storNegative)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background((delta >= 0 ? Color.storSuccess : Color.storNegative).opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.md)
        .storCard()
    }

    private var inputsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("What if…")
                .font(.storTitle3)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Add a monthly expense")
                        .font(.subheadline)
                    Spacer()
                    Text(additionalExpense == 0 ? "–" : "+\(additionalExpense.gbpRounded)/mo")
                        .font(.storTabular(.subheadline, weight: .semibold))
                        .foregroundStyle(additionalExpense > 0 ? .storWarning : .secondary)
                }
                Slider(value: $additionalExpense, in: 0...500, step: 10)
                    .tint(.storWarning)
                HStack {
                    Text("£0")
                    Spacer()
                    Text("£500")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Divider()

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Adjust savings to pot")
                        .font(.subheadline)
                    Spacer()
                    Text(savingsAdjustment == 0 ? "–" : (savingsAdjustment >= 0 ? "+" : "") + "\(savingsAdjustment.gbpRounded)/mo")
                        .font(.storTabular(.subheadline, weight: .semibold))
                        .foregroundStyle(savingsAdjustment != 0 ? .storAccent : .secondary)
                }

                Picker("Savings pot", selection: Binding(
                    get: { selectedPotID ?? appState.savingsPots.first?.id },
                    set: { selectedPotID = $0 }
                )) {
                    ForEach(appState.savingsPots) { pot in
                        Text(pot.emoji + " " + pot.name).tag(Optional(pot.id))
                    }
                }
                .pickerStyle(.menu)

                Slider(value: $savingsAdjustment, in: -200...300, step: 10)
                    .tint(.storAccent)
                HStack {
                    Text("-£200")
                    Spacer()
                    Text("+£300")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            if isModified {
                Button("Reset") {
                    withAnimation {
                        additionalExpense = 0
                        savingsAdjustment = 0
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .storCard()
    }

    private func projectionCard(pot: SavingsPot) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("\(pot.emoji) \(pot.name) projection")
                .font(.subheadline.weight(.semibold))

            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Before")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let t = baseTTG {
                        TimeToGoalBadge(result: t)
                    }
                }
                if isModified {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("After")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let t = adjustedTTG {
                            TimeToGoalBadge(result: t)
                        }
                    }
                }
            }

            Chart {
                ForEach(baseProjection, id: \.month) { point in
                    LineMark(
                        x: .value("Month", point.month),
                        y: .value("Balance", point.balance)
                    )
                    .foregroundStyle(.secondary.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 4]))
                }

                if isModified {
                    ForEach(adjustedProjection, id: \.month) { point in
                        LineMark(
                            x: .value("Month", point.month),
                            y: .value("Balance", point.balance)
                        )
                        .foregroundStyle(Color.storAccent)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }

                RuleMark(y: .value("Target", pot.target))
                    .foregroundStyle(.secondary.opacity(0.4))
                    .lineStyle(StrokeStyle(dash: [6, 3]))
                    .annotation(position: .trailing) {
                        Text("Target")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(height: 160)
            .chartXAxisLabel("Months")
            .chartYAxis {
                AxisMarks(format: .currency(code: "GBP").precision(.fractionLength(0)))
            }

            HStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.xs) {
                    Rectangle().fill(.secondary.opacity(0.5)).frame(width: 16, height: 2)
                    Text("Current").font(.caption2).foregroundStyle(.secondary)
                }
                if isModified {
                    HStack(spacing: Spacing.xs) {
                        Rectangle().fill(Color.storAccent).frame(width: 16, height: 2)
                        Text("Adjusted").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .storCard()
    }
}

#Preview {
    ForecastView()
        .environment(AppState())
}

#Preview("Dark") {
    ForecastView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
