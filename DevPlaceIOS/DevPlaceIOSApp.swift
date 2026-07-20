import SwiftUI

@main
struct DevPlaceIOSApp: App {
    @State private var appSettings = AppSettingsStore.shared

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
                .preferredColorScheme(appSettings.appearance.colorScheme)
        }
    }
}
