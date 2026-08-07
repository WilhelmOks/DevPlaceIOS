import Foundation
import Observation
import Combine

extension SignUpView {
    @Observable final class ViewModel {
        static let usernameMinLength = 3
        static let usernameMaxLength = 32
        static let emailMinLength = 3
        static let emailMaxLength = 100
        static let passwordMinLength = 6
        static let passwordMaxLength = 1024
        
        var username = ""
        var email = ""
        var password = ""
        var confirmPassword = ""
        var tosAccepted = false
        
        var alertMessage: AlertMessage = .none()
        
        var isLoading = false
        
        let succeeded: PassthroughSubject<Void, Never> = .init()
        
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        var canSubmit: Bool {
            !username.isEmpty
                && !email.isEmpty
                && !password.isEmpty
                && !confirmPassword.isEmpty
                && tosAccepted
        }
        
        func signUp() {
            if let validationError = validationError() {
                alertMessage = .presentedError(message: validationError)
                return
            }
            
            Task {
                do {
                    isLoading = true
                    defer { isLoading = false }
                    
                    try await api.signUp(
                        username: username,
                        email: email,
                        password: password,
                        confirmPassword: confirmPassword,
                    )
                    
                    succeeded.send()
                } catch {
                    alertMessage = .presentedError(error)
                }
            }
        }
        
        private func validationError() -> String? {
            if username.count < Self.usernameMinLength || username.count > Self.usernameMaxLength {
                return "Username must be between \(Self.usernameMinLength) and \(Self.usernameMaxLength) characters."
            }
            
            if !isValidUsername(username) {
                return "Username may only contain letters, numbers, hyphens, and underscores."
            }
            
            if email.count < Self.emailMinLength || email.count > Self.emailMaxLength {
                return "Email must be between \(Self.emailMinLength) and \(Self.emailMaxLength) characters."
            }
            
            if !email.contains("@") {
                return "Please enter a valid email address."
            }
            
            if password.count < Self.passwordMinLength || password.count > Self.passwordMaxLength {
                return "Password must be between \(Self.passwordMinLength) and \(Self.passwordMaxLength) characters."
            }
            
            if password != confirmPassword {
                return "The passwords do not match."
            }
            
            if !tosAccepted {
                return "Please accept the Terms of Use to continue."
            }
            
            return nil
        }
        
        private func isValidUsername(_ username: String) -> Bool {
            username.allSatisfy { character in
                character.isLetter || character.isNumber || character == "-" || character == "_"
            }
        }
    }
}
