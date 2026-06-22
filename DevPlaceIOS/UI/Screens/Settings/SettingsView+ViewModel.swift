import Foundation
import Observation
import Combine

extension SettingsView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        func logOut() {
            UserSessionStore.shared.email = nil
            UserSessionStore.shared.password = nil
            AppState.shared.token = nil
        }
    }
}
