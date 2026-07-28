import SwiftUI

struct BoxView<Content: View>: View {
    enum CornerSize {
        case small
        case normal
        case big

        var value: CGFloat {
            switch self {
            case .small: 8
            case .normal: 12
            case .big: 16
            }
        }
    }

    enum PaddingSize {
        case small
        case normal
        case big

        var value: CGFloat {
            switch self {
            case .small: 8
            case .normal: 12
            case .big: 16
            }
        }
    }

    var backgroundColor: Color = .BG_2
    var foregroundColor: Color = .FG_1
    var cornerSize: CornerSize = .normal
    var paddingSize: PaddingSize = .normal
    @ViewBuilder let content: () -> Content

    private let borderOpacity: Double = 0.25

    var body: some View {
        content()
            .foregroundStyle(foregroundColor)
            .padding(paddingSize.value)
            .overlay {
                RoundedRectangle(cornerRadius: cornerSize.value)
                    .strokeBorder(Color.FG_2.opacity(borderOpacity), lineWidth: 1)
            }
            .background {
                RoundedRectangle(cornerRadius: cornerSize.value)
                    .foregroundStyle(backgroundColor)
            }
    }
}

#Preview("Default") {
    BoxView {
        VStack(alignment: .leading, spacing: 6) {
            Text("Boxed content")
                .font(.headline)
            Text("Styled like the PollView outer box.")
                .font(.footnote)
        }
    }
    .padding()
    .background(Color.BG_1)
}

#Preview("Custom") {
    BoxView(
        backgroundColor: .BG_1,
        foregroundColor: .FG_2,
        cornerSize: .small,
        paddingSize: .big,
    ) {
        Text("Custom colors and sizes")
    }
    .padding()
    .background(Color.BG_2)
}
