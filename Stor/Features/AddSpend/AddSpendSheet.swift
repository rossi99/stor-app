import SwiftUI

/// The new-spend sheet: an amount, a category, which ledger bears it, and how
/// it is apportioned when it comes out of the joint pot.
struct AddSpendSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money

    private let keyColumns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 3)

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            header
                .padding(.bottom, 14)

            Text(appState.draft.display(money))
                .font(.display(52))
                .tracking(-1.3)
                .foregroundStyle(appState.draft.entry.isEmpty
                                 ? Color.storChevron : Color.storInk)
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xs)
                .padding(.bottom, 14)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            ChipRow(options: MockData.spendCategories, selection: $state.draft.category) { $0 }
                .padding(.horizontal, -Spacing.screen)
                .padding(.bottom, 14)

            SegmentedPill(
                options: Ledger.displayOrder,
                selection: $state.draft.ledger,
                height: 32,
                label: ledgerLabel
            )
            .padding(.bottom, Spacing.md)

            if appState.draft.showsSplit {
                splitCard
                    .padding(.bottom, 14)
            }

            keypad
                .padding(.bottom, Spacing.md)

            PrimaryButton(
                title: appState.draft.isValid
                    ? "Add \(money(appState.draft.amount, decimals: 2))"
                    : "Enter an amount",
                isEnabled: appState.draft.isValid
            ) {
                appState.commitSpend()
            }
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.top, Spacing.xl)
        .padding(.bottom, 30)
        .background(Color.storBackground)
        .animation(.easeInOut(duration: 0.2), value: appState.draft.showsSplit)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            ScreenTitle("New spend", size: 24)
            Spacer(minLength: Spacing.sm)
            Button("Cancel") { appState.cancelAddSpend() }
                .font(.text(13))
                .foregroundStyle(Color.storSecondaryLabel)
                .buttonStyle(.plain)
        }
    }

    private func ledgerLabel(_ ledger: Ledger) -> String {
        switch ledger {
        case .joint: "Joint pot"
        case .ana:   "\(appState.ana.firstName)'s"
        case .sam:   "\(appState.sam.firstName)'s"
        }
    }

    private var splitCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                MonoLabel("Who bears it", size: 9.5, tracking: 0.12)

                Spacer(minLength: Spacing.sm)

                HStack(spacing: 5) {
                    ForEach(SpendDraft.splitPresets, id: \.self) { preset in
                        presetButton(preset)
                    }
                }
            }
            .padding(.bottom, 11)

            SplitTrack(fraction: Double(appState.draft.splitPercent) / 100)

            HStack {
                MonoText("\(appState.ana.firstName) \(appState.draft.anaShare(money))",
                         size: 11.5, color: .storAna)
                Spacer(minLength: Spacing.sm)
                MonoText("\(appState.sam.firstName) \(appState.draft.samShare(money))",
                         size: 11.5, color: .storSam)
            }
            .padding(.top, 9)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .storCard(radius: Radius.md)
    }

    private func presetButton(_ preset: Int) -> some View {
        let isOn = appState.draft.splitPercent == preset

        return Button {
            appState.draft.splitPercent = preset
        } label: {
            Text("\(preset)/\(100 - preset)")
                .font(.mono(10.5))
                .foregroundStyle(isOn ? Color.storBackground : Color.storSecondaryLabel)
                .padding(.horizontal, 9)
                .frame(height: 24)
                .background(isOn ? Color.storInk : Color.storBackground)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    private var keypad: some View {
        LazyVGrid(columns: keyColumns, spacing: 7) {
            ForEach(SpendDraft.Key.layout, id: \.self) { key in
                Button {
                    appState.draft.apply(key)
                } label: {
                    Text(key.label)
                        .font(.mono(19))
                        .foregroundStyle(Color.storInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.storSurface)
                        .clipShape(.rect(cornerRadius: Radius.sm + 1, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.sm + 1, style: .continuous)
                                .strokeBorder(Color.storInk.opacity(0.08),
                                              lineWidth: Stroke.hairline)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    AddSpendSheet().environment(AppState())
}
