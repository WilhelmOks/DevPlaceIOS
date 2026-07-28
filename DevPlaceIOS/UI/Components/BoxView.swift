import SwiftUI

struct BoxView<Content: View>: View {
    enum CornerSize {
        case small
        case normal
        case big

        var value: CGFloat {
            switch self {
            case .small: 10
            case .normal: 12
            case .big: 14
            }
        }
    }

    enum PaddingSize {
        case none
        case small
        case normal
        case big

        var value: CGFloat {
            switch self {
            case .none: 0
            case .small: 10
            case .normal: 12
            case .big: 16
            }
        }
    }

    var backgroundColor: Color = .BG_2
    var foregroundColor: Color = .FG_1
    var borderColor: Color = .FG_2
    var borderOpacity: Double = 0.25
    var borderWidth: CGFloat = 1
    var cornerSize: CornerSize = .normal
    var paddingSize: PaddingSize = .normal
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .foregroundStyle(foregroundColor)
            .padding(paddingSize.value)
            .overlay {
                RoundedRectangle(cornerRadius: cornerSize.value)
                    .strokeBorder(borderColor.opacity(borderOpacity), lineWidth: borderWidth)
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
            Text("This is some additional text.")
                .font(.footnote)
                .foregroundStyle(.FG_2)
        }
    }
    .padding()
    .background(Color.BG_1)
}

#Preview("Input style") {
    BoxView(
        backgroundColor: .BG_1,
        borderOpacity: 0.5,
        cornerSize: .big,
        paddingSize: .small,
    ) {
        Text("Text inside the box")
    }
    .padding()
    .background(Color.BG_2)
}
