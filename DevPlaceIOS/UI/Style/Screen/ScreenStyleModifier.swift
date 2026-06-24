import SwiftUI

struct ScreenStyleModifier: ViewModifier {
    var backgroundColor: Color = .BG_2
    var foregroundColor: Color = .FG_1
    
    func body(content: Content) -> some View {
        content
            .background {
                backgroundColor.ignoresSafeArea()
            }
            .foregroundStyle(foregroundColor)
    }
}

extension View {
    func screenStyle(
        bgColor: Color = .BG_2,
        fgColor: Color = .FG_1
    ) -> some View {
        modifier(
            ScreenStyleModifier(
                backgroundColor: bgColor,
                foregroundColor: fgColor
            )
        )
    }
}
