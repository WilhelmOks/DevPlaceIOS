import Foundation
import Observation
import Combine

extension NotificationsView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            self.api = api
        }
    }
}
