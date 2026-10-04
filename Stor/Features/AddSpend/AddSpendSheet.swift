import SwiftUI

struct AddSpendButton: View {
    var ledger: Ledger? = nil
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(AppState.self) private var appState

    var body: some View {
        Button { appState.openAddSpend(for: ledger) } label: {
            Label(typeSize.isAccessibilitySize ? "Add" : "Add spend", systemImage: "plus")
                .storText(14, weight: .semibold)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .background(Color.storAccent, in: Capsule())
                .foregroundStyle(Color.storBackground)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add spend")
    }
}

/// Standard editable amount entry supports paste, cursor movement and VoiceOver.
struct AddSpendSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    private enum Field: Hashable { case amount, merchant }
    @FocusState private var focusedField: Field?
    @State private var showsDiscardConfirmation = false

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Amount (\(money.currency.rawValue))").storText(15, weight: .medium)
                        HStack(alignment: .firstTextBaseline) {
                            Text(money.currency.symbol)
                            TextField("0.00", text: $state.draft.entry)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .amount)
                                .accessibilityLabel("Amount in \(money.currency.rawValue)")
                                .accessibilityIdentifier("spend.amount")
                        }
                        .storDisplay(44)
                        if focusedField != .amount && !appState.draft.entry.isEmpty && !appState.draft.isValid {
                            Text("Enter an amount above zero, up to 999,999.99, with no more than two decimal places.")
                                .storText(14).foregroundStyle(Color.storNegative)
                        }
                    }

                    TextField("Merchant or note (optional)", text: $state.draft.merchant)
                        .focused($focusedField, equals: .merchant)
                        .storText(17)
                        .padding(14)
                        .background(Color.storSurface, in: RoundedRectangle(cornerRadius: Radius.md))

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Category").storText(15, weight: .medium)
                        ChipRow(options: MockData.spendCategories, selection: $state.draft.category) { $0 }
                            .padding(.horizontal, -Spacing.screen)
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Paid from").storText(15, weight: .medium)
                        Menu {
                            Picker("Paid from", selection: $state.draft.ledger) {
                                ForEach(Ledger.displayOrder) { ledger in
                                    Text(accountName(ledger)).tag(ledger)
                                }
                            }
                        } label: {
                            HStack {
                                Text(accountName(appState.draft.ledger))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: Spacing.sm)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.body)
                            }
                            .storText(17, weight: .medium)
                            .foregroundStyle(Color.storAccent)
                            .padding(14)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .background(Color.storSurface, in: RoundedRectangle(cornerRadius: Radius.md))
                        }
                        .accessibilityLabel("Paid from")
                        .accessibilityValue(accountName(appState.draft.ledger))
                        Text("This expense counts towards the selected account’s budget.")
                            .storText(14).foregroundStyle(Color.storSecondaryLabel)
                    }

                    if appState.draft.showsSplit {
                        splitCard
                    }
                }
                .padding(Spacing.screen)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.storBackground)
            .navigationTitle("New spend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if appState.draft.hasContent { showsDiscardConfirmation = true }
                        else { appState.cancelAddSpend() }
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(
                    title: appState.draft.isValid ? "Add \(money(appState.draft.amount, decimals: 2))" : "Enter an amount",
                    isEnabled: appState.draft.isValid
                ) { appState.commitSpend() }
                .accessibilityIdentifier("spend.submit")
                .padding(Spacing.screen)
                .background(Color.storBackground)
            }
        }
        .interactiveDismissDisabled(appState.draft.hasContent)
        .confirmationDialog("Discard this spend?", isPresented: $showsDiscardConfirmation, titleVisibility: .visible) {
            Button("Discard spend", role: .destructive) { appState.cancelAddSpend() }
            Button("Keep editing", role: .cancel) { }
        } message: {
            Text("The amount and note you entered haven’t been saved.")
        }
    }

    private func accountName(_ ledger: Ledger) -> String {
        ledger == .joint ? "Joint pot" : "\(appState.name(for: ledger))’s account"
    }

    private var splitCard: some View {
        @Bindable var state = appState
        return VStack(alignment: .leading, spacing: Spacing.md) {
            LabeledContent("Paid by") {
                Picker("Paid by", selection: $state.draft.paidBy) {
                    ForEach(appState.members) { member in
                        Text(member.firstName).tag(member.ledger)
                    }
                }
                .labelsHidden()
                .frame(minHeight: 44)
            }
            .font(.body)

            Text("Split between").storText(17, weight: .semibold)
            Text("Shares record who the expense is for. Payment comes from the joint pot.")
                .storText(14).foregroundStyle(Color.storSecondaryLabel)

            AdaptiveStack(spacing: Spacing.sm) {
                preset("\(appState.sam.firstName) only", share: 0)
                preset("Equal", share: 50)
                preset("\(appState.ana.firstName) only", share: 100)
            }

            Stepper(value: $state.draft.splitPercent, in: 0...100) {
                Text("\(appState.ana.firstName)’s share: \(appState.draft.splitPercent)%")
                    .storText(15)
            }
            Slider(value: Binding(get: { Double(appState.draft.splitPercent) },
                                  set: { appState.draft.splitPercent = Int($0) }), in: 0...100, step: 1)
                .accessibilityLabel("\(appState.ana.firstName)’s share")
                .accessibilityValue("\(appState.draft.splitPercent) percent")
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("\(appState.ana.firstName): \(appState.draft.splitPercent)% · \(appState.draft.anaShare(money))")
                Text("\(appState.sam.firstName): \(100 - appState.draft.splitPercent)% · \(appState.draft.samShare(money))")
            }
            .storText(15)
        }
        .padding(Spacing.lg)
        .storCard()
    }

    private func preset(_ title: String, share: Int) -> some View {
        Button(title) { appState.draft.splitPercent = share }
            .storText(14, weight: .medium)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(appState.draft.splitPercent == share ? Color.storAccentSoft : Color.storSurface,
                        in: RoundedRectangle(cornerRadius: Radius.sm))
            .accessibilityAddTraits(appState.draft.splitPercent == share ? [.isSelected] : [])
    }
}

#Preview { AddSpendSheet().environment(AppState()) }
