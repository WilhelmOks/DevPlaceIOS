import SwiftUI

struct CapsuleLabel: View {
    let text: String
    var foregroundColor: Color = .FG_1
    var backgroundColor: Color = .gray.opacity(0.5)
    
    var body: some View {
        Text(text.uppercased())
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background {
                Capsule().fill(backgroundColor)
            }
    }
}

#Preview {
    VStack(spacing: 12) {
        CapsuleLabel(text: "Lorem")
        CapsuleLabel(
            text: "Custom",
            backgroundColor: .blue,
        )
        CapsuleLabel(text: "Ipsum")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
        Color.BG_2.ignoresSafeArea()
    }
}
