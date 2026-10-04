import SwiftUI

/// The safe-to-spend hero. Takes the selected ledger's accent as its ground, so
/// switching ledger recolours the top of the screen.
struct HeroCard: View {
    let model: SafeToSpend
    let accent: Color
    let daysLeft: Int
    @Environment(\.money) private var money

    @State private var showsCalculation = false

    var body: some View {
        Button { showsCalculation = true } label: { summary }
            .buttonStyle(.plain)
            .accessibilityHint("Shows how your safe-to-spend amount is calculated")
            .sheet(isPresented: $showsCalculation) {
                NavigationStack {
                    List {
                        Section {
                            LabeledContent("Money available this month", value: money(model.pot))
                            LabeledContent("Spending so far", value: money(model.spent))
                            LabeledContent("Upcoming commitments", value: money(model.committed))
                        }
                        Section {
                            LabeledContent(model.remaining < 0 ? "Shortfall" : "Safe to spend",
                                           value: money(model.remaining))
                                .font(.headline)
                        } footer: {
                            Text("Money available, minus spending and upcoming commitments. Adding an expense updates this amount.")
                        }
                    }
                    .navigationTitle("Your spending balance")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showsCalculation = false }
                        }
                    }
                }
            }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 0) {
            AdaptiveStack(spacing: Spacing.sm) {
                MonoLabel(model.remaining < 0 ? "Spending shortfall" : model.label, size: 10.5, color: .storBackground.opacity(0.62))
                Spacer(minLength: Spacing.sm)
                MonoLabel("\(daysLeft) days left", size: 10.5, tracking: 0.06,
                          color: .storBackground.opacity(0.62))
            }

            Text(money(model.remaining))
                .storDisplay(58)
                .tracking(-1.16)
                .foregroundStyle(Color.storBackground)
                .padding(.top, 14)
                .padding(.bottom, Spacing.xxs)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(model.caption)
                .storText(13.5)
                .foregroundStyle(Color.storBackground.opacity(0.72))
                .padding(.bottom, Spacing.xl)

            GeometryReader { geometry in
                let total = max(max(model.pot, model.spent + model.committed), 1)
                HStack(spacing: 0) {
                    Rectangle().fill(Color.storBackground.opacity(0.45))
                        .frame(width: geometry.size.width * max(0, model.spent) / total)
                    Rectangle().fill(Color.storBackground.opacity(0.8))
                        .frame(width: geometry.size.width * max(0, model.committed) / total)
                    Rectangle().fill(Color.storLime)
                }
                .clipShape(Capsule())
            }
            .frame(height: 8)
            .accessibilityHidden(true)

            ViewThatFits(in: .horizontal) {
                HStack { legend("Spent", opacity: 0.45); legend("Committed", opacity: 0.8); legend("Available", opacity: 1, lime: true) }
                VStack(alignment: .leading) { legend("Spent", opacity: 0.45); legend("Committed", opacity: 0.8); legend("Available", opacity: 1, lime: true) }
            }
            .padding(.top, Spacing.sm)

            AdaptiveStack(spacing: Spacing.sm) {
                MonoText("\(money(model.spent)) spent", size: 11,
                         color: .storBackground.opacity(0.66))
                Spacer()
                MonoText("\(money(model.pot)) in", size: 11,
                         color: .storBackground.opacity(0.66))
            }
            .padding(.top, 9)

            Label("View calculation", systemImage: "chevron.right")
                .storText(14, weight: .medium)
                .foregroundStyle(Color.storBackground)
                .padding(.top, Spacing.md)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storSolidCard(radius: Radius.xxl, fill: accent)
    }
    private func legend(_ text: String, opacity: Double, lime: Bool = false) -> some View {
        HStack(spacing: 5) {
            Circle().fill(lime ? Color.storLime : Color.storBackground.opacity(opacity))
                .frame(width: 6, height: 6)
            Text(text).storText(12).foregroundStyle(Color.storBackground)
        }
    }

}
