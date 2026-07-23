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
        guard let currentFeed = feed, let cursor = currentFeed.nextCursor else {
            return
        }
        let nextPage = try await api.feed(before: cursor)
        feed = Feed(
            posts: currentFeed.posts + nextPage.posts,
            currentTab: nextPage.currentTab,
            currentTopic: nextPage.currentTopic,
            search: nextPage.search,
            nextCursor: nextPage.nextCursor,
            totalMembers: nextPage.totalMembers,
            postsToday: nextPage.postsToday,
            totalProjects: nextPage.totalProjects,
            totalGists: nextPage.totalGists,
            topAuthors: nextPage.topAuthors,
        )
    }
    
    func clear() {
        feed = nil
    }
}
