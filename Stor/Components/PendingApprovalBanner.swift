import SwiftUI

struct PendingApprovalBanner: View {
    let count: Int
    var onReview: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "clock.badge.exclamationmark.fill")
                .foregroundStyle(.orange)
                .font(.body)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count) expense\(count == 1 ? "" : "s") awaiting approval")
                    .font(.subheadline.weight(.medium))
                Text("Tap to review")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.md)
        .background(Color.orange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .strokeBorder(Color.orange.opacity(0.25), lineWidth: 1)
        )
        .onTapGesture { onReview?() }
    }
}

#Preview {
    PendingApprovalBanner(count: 1)
        .padding()
}
