import Foundation
import Observation
import Combine

extension FeedView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        var alertMessage: AlertMessage = .none()
        
        var isLoadingMore = false
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        func load() async {
            do {
                try await AppState.shared.loadFeed(api: api)
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
        
        func loadMore() async {
            guard !isLoadingMore else { return }
            isLoadingMore = true
            defer { isLoadingMore = false }
            do {
                try await AppState.shared.loadMoreFeed(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
