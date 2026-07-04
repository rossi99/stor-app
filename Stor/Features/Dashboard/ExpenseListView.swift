import SwiftUI

struct ExpenseListView: View {
    @Environment(AppState.self) private var appState
    @State private var showAdd = false
    @State private var filterCategory: ExpenseCategory? = nil

    private var filtered: [Expense] {
        guard let cat = filterCategory else { return appState.expenses }
        return appState.expenses.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            List {
                if appState.pendingExpenseCount > 0 {
                    Section {
                        PendingApprovalBanner(count: appState.pendingExpenseCount)
                            .listRowInsets(.init())
                            .listRowBackground(Color.clear)
                    }
                }

                Section {
                    Picker("Filter", selection: $filterCategory) {
                        Text("All").tag(Optional<ExpenseCategory>.none)
                        ForEach(ExpenseCategory.allCases) { cat in
                            Text(cat.rawValue).tag(Optional(cat))
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Category")
                }
                .listRowBackground(Color.storSurface)

                Section {
                    ForEach(filtered) { expense in
                        ExpenseRow(expense: expense, members: appState.household.members)
                    }
                } header: {
                    HStack {
                        Text("Expenses")
                        Spacer()
                        Text(filtered.reduce(0) { $0 + $1.monthlyAmount }.gbpRounded + "/mo")
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(Color.storSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.storBackground)
            .navigationTitle("All Expenses")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddExpenseView()
            }
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let members: [Member]
    var showAddedBy: Bool = false

    private var addedByName: String {
        members.first { $0.id == expense.addedBy }?.firstName ?? "Unknown"
    }

    private var subtitle: String {
        if showAddedBy { return "Requested by \(addedByName)" }
        return "\(expense.category.rawValue) · \(expense.frequency.rawValue.lowercased())"
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(categoryColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: expense.category.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Text(expense.name)
                        .font(.subheadline.weight(.medium))
                    if !expense.approvalStatus.isApproved && !showAddedBy {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(expense.monthlyAmount.gbpRounded)
                    .font(.storTabular(.subheadline, weight: .semibold))
                Text("/mo")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var categoryColor: Color {
        switch expense.category {
        case .bills:          return .blue
        case .subscriptions:  return .purple
        case .sinkingFunds:   return .storAccent
        case .groceries:      return .green
        case .transport:      return .orange
        case .eatingOut:      return .red
        case .entertainment:  return .pink
        case .health:         return .mint
        case .clothing:       return .indigo
        case .other:          return .gray
        }
    }
}

#Preview {
    ExpenseListView()
        .environment(AppState())
}

#Preview("Dark") {
    ExpenseListView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
