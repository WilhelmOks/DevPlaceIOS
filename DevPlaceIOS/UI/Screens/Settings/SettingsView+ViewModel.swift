import Foundation
import Observation
import Combine

extension SettingsView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        func logOut() async {
            await PushNotificationManager.shared.unregisterForPushNotifications(api: api)
            UserSessionStore.shared.email = nil
            UserSessionStore.shared.password = nil
            AppState.shared.clear()
            try? await AppState.shared.loadFeed(api: api)
        }
        
        func deleteAccount() async {
            do {
                try await api.deleteAccount()
                await logOut()
            } catch {
                dlog("Failed to delete account: \(error)")
            }
        }
    }
}
