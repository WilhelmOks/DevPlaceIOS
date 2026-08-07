import SwiftUI
import MarkdownUI

struct SignUpView: View {
    @Environment(\.api) var api
    
    var body: some View {
        SignUpViewContent(viewModel: .init(api: api))
    }
}

private struct SignUpViewContent: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: SignUpView.ViewModel
    
    @State private var isShowingTermsOfUse = false
    @State private var isShowingSuccess = false
    
    @FocusState private var focusedField: Field?
    
    private let characterCounterHorizontalPadding = 10.0
    
    private enum Field {
        case username
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        content()
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .background {
                Color.BG_2.ignoresSafeArea()
            }
            .foregroundStyle(.FG_1)
            .navigationBarTitle("Create account")
            .alert($viewModel.alertMessage)
            .alert("Account created", isPresented: $isShowingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your account has been created. You can now sign in.")
            }
            .sheet(isPresented: $isShowingTermsOfUse) {
                TermsOfUseSheet()
            }
            .onReceive(viewModel.succeeded) {
                isShowingSuccess = true
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack(spacing: 26) {
                textFields()
                
                termsOfUse()
                
                signUpButton()
            }
            .padding()
        }
    }
    
    @ViewBuilder private func textFields() -> some View {
        VStack(spacing: 10) {
            field {
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
            } counter: {
                CharacterCounterView(
                    text: viewModel.username,
                    minCount: SignUpView.ViewModel.usernameMinLength,
                    maxCount: SignUpView.ViewModel.usernameMaxLength,
                )
            }
            
            field {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
            } counter: {
                CharacterCounterView(
                    text: viewModel.email,
                    minCount: SignUpView.ViewModel.emailMinLength,
                    maxCount: SignUpView.ViewModel.emailMaxLength,
                )
            }
            
            field {
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
            } counter: {
                CharacterCounterView(
                    text: viewModel.password,
                    minCount: SignUpView.ViewModel.passwordMinLength,
                    maxCount: SignUpView.ViewModel.passwordMaxLength,
                )
            }
            
            field {
                SecureField("Confirm password", text: $viewModel.confirmPassword)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.go)
                    .onSubmit {
                        submit()
                    }
            } counter: {
                CharacterCounterView(
                    text: viewModel.confirmPassword,
                    minCount: SignUpView.ViewModel.passwordMinLength,
                    maxCount: SignUpView.ViewModel.passwordMaxLength,
                )
            }
        }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .textFieldStyle(.devPlace)
        .disabled(viewModel.isLoading)
    }
    
    @ViewBuilder private func field<Input: View, Counter: View>(
        @ViewBuilder input: () -> Input,
        @ViewBuilder counter: () -> Counter,
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            input()
            
            counter()
                .padding(.horizontal, characterCounterHorizontalPadding)
        }
    }
    
    @ViewBuilder private func termsOfUse() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                isShowingTermsOfUse = true
            } label: {
                Text("Read the Terms of Use")
            }
            .foregroundStyle(Color.accentColor)
            
            Toggle(isOn: $viewModel.tosAccepted) {
                Text("I accept the Terms of Use")
                    .foregroundStyle(.FG_2)
            }
            .tint(Color.accentColor)
            .disabled(viewModel.isLoading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder private func signUpButton() -> some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
            
            Button {
                submit()
            } label: {
                Text("Create account")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.accentGradient)
            .bold()
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.isLoading ? 0 : 1)
        }
    }
    
    private func submit() {
        focusedField = nil
        viewModel.signUp()
    }
}

private struct TermsOfUseSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Markdown(Self.placeholderText)
                    .markdownTheme(.devPlace)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background {
                Color.BG_2.ignoresSafeArea()
            }
            .foregroundStyle(.FG_1)
            .navigationBarTitle("Terms of Use")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // TODO: Replace this placeholder with the real Terms of Use text.
    private static let placeholderText = """
    # Terms of Use
    
    _This is placeholder text. The real Terms of Use will be provided later._
    
    By creating an account you agree to the terms that will appear here.
    """
}

#Preview("mock") {
    NavigationStack {
        SignUpView()
            .environment(\.api, .mock)
    }
}
