import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.storAccent.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Text(initials)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.storAccent)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appState.personalDetails.name)
                                .font(.headline)
                            Text(appState.household.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                }
                .listRowBackground(Color.storSurface)

                Section("Household") {
                    NavigationLink(destination: HouseholdDetailsView()) {
                        Label("Household details", systemImage: "house.fill")
                    }
                }
                .listRowBackground(Color.storSurface)

                Section("Personal") {
                    NavigationLink(destination: PersonalDetailsView()) {
                        Label("Personal details", systemImage: "person.fill")
                    }
                    NavigationLink(destination: TaxInfoView()) {
                        Label("Tax information", systemImage: "doc.text.fill")
                    }
                }
                .listRowBackground(Color.storSurface)

                Section("Account") {
                    Button(role: .destructive) {
                        appState.isAuthenticated = false
                        appState.hasHousehold    = false
                    } label: {
                        Label("Sign out", systemImage: "arrow.backward.circle")
                    }
                }
                .listRowBackground(Color.storSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var initials: String {
        appState.personalDetails.name
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}

#Preview("Dark") {
    ProfileView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
