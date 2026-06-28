import SwiftUI

/// A circular profile button that presents the `ProfileView` as a sheet.
struct ProfileButton: View {
    @Environment(AppState.self) private var appState
    @State private var showProfile = false

    var body: some View {
        Button {
            showProfile = true
        } label: {
            Text(initials)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.storAccent)
                .frame(width: 40, height: 40)
                .background(Color.storAccent.opacity(0.15), in: Circle())
        }
        .accessibilityLabel("Profile")
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }

    /// The user's first-name and surname initials, e.g. "JS" for "Jane Smith".
    private var initials: String {
        let parts = appState.personalDetails.name
            .split(separator: " ")
            .map(String.init)
        let first = parts.first?.first
        let last  = parts.count > 1 ? parts.last?.first : nil
        return [first, last].compactMap { $0 }.map(String.init).joined().uppercased()
    }
}

/// A large page title with the profile button inline on the trailing edge.
struct PageHeader: View {
    let title: String

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.storLargeTitle)
            Spacer()
            ProfileButton()
        }
    }
}
