import SwiftUI

@main
struct DevPlaceIOSApp: App {
    init() {
        let api: DevPlaceApi = .prod
        let userSessionStore = UserSessionStore.shared
        
        if let email = userSessionStore.email, let password = userSessionStore.password {
            Task {
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
