import SwiftUI

struct MemberRow: View {
    let member: Member
    var footnote: String? = nil

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.storAccent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(initials)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.storAccent)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Text(member.name)
                        .font(.subheadline.weight(.medium))
                    if member.isCreator {
                        Text("Owner")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
                if let footnote {
                    Text(footnote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private var initials: String {
        member.name
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
    }
}

#Preview {
    VStack {
        MemberRow(member: MockData.sarah, footnote: "sarah@themurphys.co.uk")
        MemberRow(member: MockData.james, footnote: "james@themurphys.co.uk")
    }
    .padding()
}
