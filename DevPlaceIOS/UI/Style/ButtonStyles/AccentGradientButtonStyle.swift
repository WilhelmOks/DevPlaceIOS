import SwiftUI

struct AccentGradientButtonStyle: ButtonStyle {
    enum Shape {
        case roundedRectangle
        case circle
    }

    var shape: Shape = .roundedRectangle

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                background
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

    @ViewBuilder
    private var background: some View {
        switch shape {
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 14.0)
        case .circle:
            Circle()
        }
    }
}

extension ButtonStyle where Self == AccentGradientButtonStyle {
    static var accentGradient: Self { Self() }

    static func accentGradient(shape: AccentGradientButtonStyle.Shape) -> Self {
        Self(shape: shape)
    }
}

#Preview {
    VStack {
        Button("Hello, World!") {
            
        }
        .buttonStyle(.accentGradient)
        
        Button("+") {
            
        }
        .buttonStyle(.accentGradient(shape: .circle))
    }
}
