import SwiftUI

struct LogInView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: LogInView.ViewModel
    
    init(api: DevPlaceApi = .prod) {
        _viewModel = .init(wrappedValue: .init(api: api))
    }
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
            .onReceive(viewModel.dismiss) {
                dismiss()
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack {
                textFields()
                logInButton()
            }
            .padding()
        }
    }
    
    @ViewBuilder private func textFields() -> some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
        }
    }
    
    @ViewBuilder private func logInButton() -> some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
            
            Button("Log in") {
                viewModel.logIn()
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.isLoading ? 0 : 1)
        }
    }
}

#Preview("mock") {
    LogInView(api: .mock)
}

#Preview("prod") {
    LogInView()
}
