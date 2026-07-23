import Foundation
import Observation
import DevPlaceSwiftSDK

@Observable
final class AppState {
    static let shared = AppState()
    
    private init() {}
    
    var token: AuthToken?
    
    var isLoggedIn: Bool { token != nil }
    
    var feed: Feed?
    
    func loadFeed(api: DevPlaceApi) async throws {
        AppState.shared.feed = try await api.feed()
    }
    
    func loadMoreFeed(api: DevPlaceApi) async throws {
        //TODO: implement
    }
    
    func clear() {
        feed = nil
    }
}
