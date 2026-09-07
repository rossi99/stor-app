import SwiftUI

/// Who is in the household, how the money is set up, and a way back to setup.
struct HouseholdView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.money) private var money
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "Household") { dismiss() }

            ScrollView {
                VStack(spacing: 14) {
                    RowCard {
                        ForEach(Array(appState.members.enumerated()), id: \.element.id) { index, member in
                            memberRow(member, isFirst: index == 0)
                        }
                    }

                    RowCard {
                        ForEach(Array(preferences.enumerated()), id: \.offset) { index, pref in
                            preferenceRow(pref.label, pref.value, isFirst: index == 0)
                        }
                    }

                    Button {
                        appState.replaySetup()
                    } label: {
                        Text("Replay setup")
                            .font(.text(14))
                            .foregroundStyle(Color.storSecondaryLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .overlay {
                                Capsule().strokeBorder(Color.storInk.opacity(0.14),
                                                       lineWidth: Stroke.hairline)
                            }
                    }
                    .buttonStyle(.plain)
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

    private var preferences: [(label: String, value: String)] {
        [
            ("Money model", appState.moneyModel.settingsLabel),
            ("Currency", appState.currency.rawValue),
            ("Personal privacy", "Totals only"),
            ("Payslip check", appState.showPayslipCheck ? "On" : "Off"),
            ("Pot top-up day", "10th"),
        ]
    }

    private func memberRow(_ member: HouseholdMember, isFirst: Bool) -> some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            HStack(spacing: 13) {
                Text(member.initials)
                    .font(.mono(12.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(member.ledger.accent)
                    .clipShape(.circle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(member.name)
                        .font(.text(15, weight: .medium))
                        .tracking(-0.12)
                        .foregroundStyle(Color.storInk)
                    MonoText(member.role, size: 11, color: .storTertiaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                MonoText("\(money(member.contribution))/mo", size: 11,
                         color: .storTertiaryLabel)
            }
            .padding(15)
        }
    }

    private func preferenceRow(_ label: String, _ value: String, isFirst: Bool) -> some View {
        VStack(spacing: 0) {
            RowSeparator(isVisible: !isFirst)

            HStack(spacing: Spacing.md) {
                Text(label)
                    .font(.text(14.5))
                    .tracking(-0.0725)
                    .foregroundStyle(Color.storInk)
                    .frame(maxWidth: .infinity, alignment: .leading)

                MonoText(value, size: 12, color: .storTertiaryLabel)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.storChevron)
            }
            .padding(15)
        }
    }
}

#Preview {
    HouseholdView().environment(AppState())
}
