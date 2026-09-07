import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        ZStack(alignment: .bottom) {
            Color.storBackground.ignoresSafeArea()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBar()
        }
        .sheet(isPresented: $state.isAddingSpend) {
            AddSpendSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.sheet)
        }
    }

    @ViewBuilder
    private var content: some View {
        @Bindable var state = appState

        switch appState.selectedTab {
        case .home:
            NavigationStack(path: $state.homePath) {
                HomeView().withRoutes()
            }
        case .ledger:
            LedgerView()
        case .budget:
            BudgetView()
        case .goals:
            GoalsView()
        case .wealth:
            NavigationStack(path: $state.wealthPath) {
                WealthView().withRoutes()
            }
        }
    }
}

private extension View {
    /// Every pushed screen is reachable from either stack, so both register the
    /// same destinations.
    func withRoutes() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .bills:     BillsView()
            case .alerts:    AlertsView()
            case .household: HouseholdView()
            case .recap:     RecapView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// The custom tab bar, with the add-spend button floating above its right edge.
/// Native `Tab` can't carry mono uppercase labels, which are a signature of this
/// design, so the bar is drawn here instead.
struct TabBar: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                item(tab)
            }
        }
        .padding(.top, Spacing.xxs)
        .background {
            Color.storBackground.opacity(0.94)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.storBorder)
                .frame(height: Stroke.hairline)
        }
        .overlay(alignment: .topTrailing) {
            addButton
                .offset(x: -Spacing.screen, y: -60)
        }
    }

    private func item(_ tab: AppTab) -> some View {
        let isOn = appState.selectedTab == tab
        let color = isOn ? Color.storInk : Color(red: 0.627, green: 0.635, blue: 0.659)

        return Button {
            appState.selectedTab = tab
        } label: {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 17, weight: .regular))
                    .frame(height: 20)

                MonoLabel(tab.title, size: 9, tracking: 0.08, color: color)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var addButton: some View {
        Button {
            appState.openAddSpend()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Color.storBackground)
                .frame(width: 52, height: 52)
                .background(Color.storInk)
                .clipShape(.circle)
                .shadow(color: Color.storInk.opacity(0.24), radius: 10, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView().environment(AppState())
}
