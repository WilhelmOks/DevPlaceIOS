import Foundation
import Observation
import Combine

extension LogInView {
    @Observable final class ViewModel {
        var email: String
        var password: String
        
        var alertMessage: AlertMessage = .none()
        
        var isLoading = false
        
        let dismiss: PassthroughSubject<Void, Never> = .init()
        
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            let store = UserSessionStore.shared
            
            email = store.email ?? ""
            password = store.password ?? ""
            
            self.api = api
        }
        
        var canSubmit: Bool {
            !email.isEmpty && !password.isEmpty
        }
        
        func logIn() {
            let store = UserSessionStore.shared
            
            store.email = email
            store.password = password
            
            Task {
                do {
                    isLoading = true
                    defer { isLoading = false }
                    
                    try await api.logIn(email: email, password: password)
                    
                    dismiss.send()
                } catch {
                    alertMessage = .presentedError(error)
                }
            }
        }
    }
}
