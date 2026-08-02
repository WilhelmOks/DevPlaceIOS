import SwiftUI

struct DevPlaceTextFieldStyle: TextFieldStyle {
    var backgroundColor: Color = .BG_1
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        BoxView(
            backgroundColor: backgroundColor,
            borderOpacity: 0.5,
            cornerSize: .big,
            paddingSize: .small,
        ) {
            configuration
        }
    }
}

extension TextFieldStyle where Self == DevPlaceTextFieldStyle {
    static var devPlace: Self { Self() }
    
    static func devPlace(backgroundColor: Color) -> Self {
        Self(backgroundColor: backgroundColor)
    }
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
