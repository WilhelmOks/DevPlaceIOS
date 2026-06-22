import SwiftUI

@main
struct DevPlaceIOSApp: App {
    init() {
        let userSessionStore = UserSessionStore.shared
        
        if let email = userSessionStore.email, let password = userSessionStore.password {
            Task {
                let api: DevPlaceApi = .prod
                try await api.logIn(email: email, password: password)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}
