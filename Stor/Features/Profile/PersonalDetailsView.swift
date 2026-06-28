import SwiftUI

struct PersonalDetailsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            Section("Personal") {
                LabeledContent("Full name", value: appState.personalDetails.name)
                LabeledContent("Email", value: appState.personalDetails.email)
                LabeledContent("Age", value: "\(appState.personalDetails.age)")
                LabeledContent("Gender", value: appState.personalDetails.gender)
            }
            .listRowBackground(Color.storSurface)

            Section("Preferences") {
                LabeledContent("Currency", value: "GBP (£)")
            }
            .listRowBackground(Color.storSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.storBackground)
        .navigationTitle("Personal details")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        PersonalDetailsView()
            .environment(AppState())
    }
}
