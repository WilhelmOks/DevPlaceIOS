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
        
        func refresh() async {
            do {
                let newFeed = try await api.feed()
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(300))
                    AppState.shared.feed = newFeed
                }
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
