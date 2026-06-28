import SwiftUI

enum HouseholdSetupMode: CaseIterable {
    case create, join

    var title: String { self == .create ? "Create" : "Join" }
}

struct HouseholdSetupView: View {
    @Environment(AppState.self) private var appState

    @State private var mode: HouseholdSetupMode
    @State private var householdName    = ""
    @State private var selectedFramework = Framework.fiftyThirtyTwenty
    @State private var requireApprovals = true
    @State private var inviteCode       = ""

    init(mode: HouseholdSetupMode = .create) {
        _mode = State(initialValue: mode)
    }

    private var canProceed: Bool {
        switch mode {
        case .create: return !householdName.trimmingCharacters(in: .whitespaces).isEmpty
        case .join:   return inviteCode.count >= 4
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                modePicker
                headerSection

                switch mode {
                case .create: createSection
                case .join:   joinSection
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
        }
        .background(Color.storBackground)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button { proceed() } label: {
                Text(mode == .create ? "Create household" : "Join household")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Color.storAccent : Color(.systemFill))
                    .foregroundStyle(canProceed ? .white : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            }
            .disabled(!canProceed)
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.md)
            .background(Color.storBackground)
        }
    }

    private var modePicker: some View {
        Picker("Household setup", selection: $mode.animation(.easeInOut)) {
            ForEach(HouseholdSetupMode.allCases, id: \.self) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(mode == .create ? "Create a household" : "Join a household")
                .font(.storLargeTitle)
            Text(mode == .create
                 ? "Set up your shared financial space"
                 : "Enter the invite code from your partner")
                .foregroundStyle(.secondary)
        }
    }

    private var createSection: some View {
        VStack(spacing: Spacing.lg) {
            FloatingLabelField(label: "Household name", text: $householdName)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Financial framework")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                VStack(spacing: Spacing.xs) {
                    ForEach(Framework.allOptions, id: \.label) { framework in
                        FrameworkOptionRow(framework: framework, isSelected: selectedFramework.label == framework.label) {
                            selectedFramework = framework
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Approvals")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Require expense approval")
                            .font(.subheadline.weight(.medium))
                        Text("New expenses need sign-off from all members")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $requireApprovals)
                        .labelsHidden()
                }
                .padding(Spacing.md)
                .background(Color.storSurface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            }
        }
    }

    private var joinSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            FloatingLabelField(label: "Invite code", text: $inviteCode, keyboard: .default)
            Text("Ask your household creator for the 8-character code")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func proceed() {
        appState.isAuthenticated = true
        appState.hasHousehold    = true
    }
}

struct FrameworkOptionRow: View {
    let framework: Framework
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(framework.label)
                        .font(.subheadline.weight(.semibold))
                    Text(descriptionFor(framework))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.storAccent)
                }
            }
            .padding(Spacing.md)
            .background(Color.storSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .strokeBorder(isSelected ? Color.storAccent : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func descriptionFor(_ f: Framework) -> String {
        "\(Int(f.needsPercent*100))% needs · \(Int(f.wantsPercent*100))% wants · \(Int(f.savingsPercent*100))% savings"
    }
}

#Preview {
    NavigationStack {
        HouseholdSetupView(mode: .create)
            .environment(AppState())
    }
}

#Preview("Dark – Join") {
    NavigationStack {
        HouseholdSetupView(mode: .join)
            .environment(AppState())
            .preferredColorScheme(.dark)
    }
}
