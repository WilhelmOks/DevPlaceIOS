import SwiftUI

struct FormButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .foregroundStyle(
                configuration.isPressed ? Color.gray : Color.FG_1
            )
            //.fontWeight(.medium)
    }
}

extension ButtonStyle where Self == FormButtonStyle {
    static var form: Self { Self() }
}

#Preview {
    Form {
        Button("Tap me!") {
            
        }
        .buttonStyle(.form)
    }
}
