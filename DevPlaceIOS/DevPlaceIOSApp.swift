import SwiftUI

@main
struct DevPlaceIOSApp: App {
    @State private var appSettings = AppSettingsStore.shared

    init() {
        let userSessionStore = UserSessionStore.shared
        let api: DevPlaceApi = .prod

        if let email = userSessionStore.email, let password = userSessionStore.password {
            Task {
                try await api.logIn(email: email, password: password)
                try await AppState.shared.loadFeed(api: api)
            }
        } else {
            Task {
                try await AppState.shared.loadFeed(api: api)
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
