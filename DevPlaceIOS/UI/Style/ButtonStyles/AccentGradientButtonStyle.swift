import SwiftUI

struct AccentGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14.0)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.agStart, .agEnd]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
                    .shadow(color: .accentColor.opacity(0.5), radius: 5)
            )
            .foregroundColor(.AFG)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension ButtonStyle where Self == AccentGradientButtonStyle {
    static var accentGradient: Self { Self() }
}

#Preview {
    Button("Hello, World!") {
        
    }
    .buttonStyle(.accentGradient)
}

