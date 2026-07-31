import Foundation
import Observation
import DevPlaceSwiftSDK

@Observable
@MainActor
final class AppState {
    static let shared = AppState()
    
    private init() {}
    
    var token: AuthToken?
    
    var isLoggedIn: Bool { token != nil }
    
    var currentUser: User?
    
    var feed: Feed?

    var unreadNotificationCount = 0

    func isCurrentUser(id: String) -> Bool {
        currentUser?.id == id
    }
    
    func loadFeed(api: DevPlaceApi) async throws {
        AppState.shared.feed = try await api.feed()
        await loadUnreadNotificationCount(api: api)
    }

    func loadUnreadNotificationCount(api: DevPlaceApi) async {
        do {
            unreadNotificationCount = try await api.notificationCounts().notifications
        } catch {
            dlog("Failed to load unread notification count: \(error)")
        }
    }
    
    func loadMoreFeed(api: DevPlaceApi) async throws {
        guard let currentFeed = feed, let cursor = currentFeed.nextCursor else {
            return
        }
        let nextPage = try await api.feed(before: cursor)
        let existingIds = Set(currentFeed.posts.map(\.id))
        for duplicate in nextPage.posts where existingIds.contains(duplicate.id) {
            dlog("load-more in feed returned duplicate post from backend: \(duplicate.id)")
        }
        let newPosts = nextPage.posts.filter { !existingIds.contains($0.id) }
        feed = Feed(
            posts: currentFeed.posts + newPosts,
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
        currentUser = nil
        unreadNotificationCount = 0
    }
}
