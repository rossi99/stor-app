import SwiftUI

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .background(Color.storSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .shadow(
                color: Color(red: 0.235, green: 0.176, blue: 0.098).opacity(scheme == .dark ? 0.30 : 0.06),
                radius: 16, x: 0, y: 2
            )
    }
}

struct FlatCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.storSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
    }
}

extension View {
    func storCard() -> some View { modifier(CardModifier()) }
    func storFlatCard() -> some View { modifier(FlatCardModifier()) }
}
