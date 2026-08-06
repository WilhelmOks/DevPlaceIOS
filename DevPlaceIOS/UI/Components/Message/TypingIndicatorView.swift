import SwiftUI

struct TypingIndicatorView: View {
    let username: String

    @State private var isAnimating = false

    @ScaledMetric private var dotSize = 5

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 10)
    }

    var body: some View {
        HStack(spacing: dotSize * 0.6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.FG_2)
                    .frame(width: dotSize, height: dotSize)
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating,
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.BG_1)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(Color.FG_2.opacity(0.12), lineWidth: 1)
        }
        .onAppear { isAnimating = true }
        .accessibilityLabel(Text("\(username) is typing"))
    }
}

#Preview {
    TypingIndicatorView(username: "alice")
        .padding()
        .screenStyle(bgColor: .BG_2)
}
