import Foundation
import Observation
import Combine

extension FeedView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        var alertMessage: AlertMessage = .none()
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        func load() async {
            do {
                AppState.shared.feed = try await api.feed()
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
