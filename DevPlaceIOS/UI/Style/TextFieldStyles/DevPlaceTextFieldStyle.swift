import SwiftUI

struct DevPlaceTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.FG_2.opacity(0.5))
                    .fill(.BG_1)
            }
    }
}

extension TextFieldStyle where Self == DevPlaceTextFieldStyle {
    static var devPlace: Self { Self() }
}

#Preview {
    VStack(spacing: 10) {
        TextField("Email", text: .constant(""))

        SecureField("Password", text: .constant(""))
    }
    .textFieldStyle(.devPlace)
    .padding()
    .background {
        Color.BG_2.ignoresSafeArea()
    }
}
