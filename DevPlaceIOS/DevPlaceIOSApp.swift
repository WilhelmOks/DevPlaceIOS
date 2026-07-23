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
                AppState.shared.feed = try await api.feed()
            }
        } else {
            Task {
                AppState.shared.feed = try await api.feed()
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
