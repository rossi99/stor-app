import SwiftUI

struct TimeToGoalBadge: View {
    let result: TimeToGoalResult

    private var badgeColor: Color {
        result.isOnTrack ? .storSuccess : .storWarning
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: result.isOnTrack ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.caption2.weight(.semibold))
            Text("\(result.statusLabel) · \(result.label)")
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        TimeToGoalBadge(result: TimeToGoalResult(months: 5, isOnTrack: true,
            targetDate: Calendar.current.date(byAdding: .month, value: 5, to: Date())!))
        TimeToGoalBadge(result: TimeToGoalResult(months: 14, isOnTrack: false,
            targetDate: Calendar.current.date(byAdding: .month, value: 14, to: Date())!))
    }
    .padding()
}
