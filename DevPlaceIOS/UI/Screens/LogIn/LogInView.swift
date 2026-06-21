import SwiftUI

struct LogInView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: LogInView.ViewModel
    
    init(api: DevPlaceApi = .prod) {
        _viewModel = .init(wrappedValue: .init(api: api))
    }
    
    var body: some View {
        NavigationStack {
            content()
                .background {
                    Color.BG_2.ignoresSafeArea()
                }
                .foregroundStyle(.FG_1)
                .navigationBarTitle("Sign in")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .alert($viewModel.alertMessage)
                .onReceive(viewModel.dismiss) {
                    dismiss()
                }
        }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack(spacing: 26) {
                textFields()
                
                logInButton()
                
                forgotPassword()
                
                createNewAccount()
            }
            .padding()
        }
    }
    
    @ViewBuilder private func textFields() -> some View {
        VStack(spacing: 10) {
            Group {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.FG_2)
                    .fill(.BG_1)
            }
        }
    }
    
    @ViewBuilder private func logInButton() -> some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
            
            Button("Sign in") {
                viewModel.logIn()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .bold()
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.isLoading ? 0 : 1)
        }
    }
    
    @ViewBuilder private func forgotPassword() -> some View {
        Link(
            destination: URL(string: "https://devplace.net/auth/forgot-password")!
        ) {
            Text("Forgot your password?")
        }
        .foregroundStyle(Color.accentColor)
    }
    
    @ViewBuilder private func createNewAccount() -> some View {
        let text = Text("Don't have an account?")
            .fontWeight(.medium)
            .foregroundStyle(.FG_2)
        
        let link = Link(
            destination: URL(string: "https://devplace.net/auth/signup")!
        ) {
            Text("Create new account").bold()
        }
        .foregroundStyle(Color.accentColor)
        
        ViewThatFits {
            HStack(spacing: 8) {
                text
                link
            }
            
            VStack(spacing: 2) {
                text
                link
            }
        }
    }
}

#Preview("mock") {
    LogInView(api: .mock)
}

#Preview("prod") {
    LogInView()
}
