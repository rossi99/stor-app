import SwiftUI

struct HouseholdDetailsView: View {
    @Environment(AppState.self) private var appState
    @State private var showFrameworkPicker = false

    private var household: Household { appState.household }

    var body: some View {
        List {
            Section("Household") {
                LabeledContent("Name", value: household.name)
                LabeledContent("Members", value: "\(household.members.count)")
                LabeledContent("Member since", value: household.memberSince.dayMonthYear)
                LabeledContent("Invite code", value: household.inviteCode)
            }
            .listRowBackground(Color.storSurface)

            Section("Members") {
                ForEach(household.members) { member in
                    MemberRow(member: member, footnote: member.email)
                }
            }
            .listRowBackground(Color.storSurface)

            Section("Financial framework") {
                HStack {
                    Text("Current framework")
                    Spacer()
                    Text(household.framework.label)
                        .foregroundStyle(Color.storAccent)
                        .fontWeight(.semibold)
                }
                ForEach(Framework.allOptions, id: \.label) { fw in
                    Button {
                        appState.household.framework = fw
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fw.label)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text("\(Int(fw.needsPercent*100))% needs · \(Int(fw.wantsPercent*100))% wants · \(Int(fw.savingsPercent*100))% savings")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if household.framework.label == fw.label {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.storAccent)
                            }
                        }
                    }
                }
            }
            .listRowBackground(Color.storSurface)

            Section("Settings") {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Require expense approval")
                            .font(.subheadline)
                        Text("All members must agree before an expense is counted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { appState.household.requiresApprovals },
                        set: { appState.household.requiresApprovals = $0 }
                    ))
                    .labelsHidden()
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Split surplus")
                            .font(.subheadline)
                        Text(household.surplusSplitMethod.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Picker("Split surplus", selection: Binding(
                        get: { appState.household.surplusSplitMethod },
                        set: { appState.household.surplusSplitMethod = $0 }
                    )) {
                        ForEach(SurplusSplitMethod.allCases) { method in
                            Text(method.label).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
            }
            .listRowBackground(Color.storSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.storBackground)
        .navigationTitle("Household")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        HouseholdDetailsView()
            .environment(AppState())
    }
}
