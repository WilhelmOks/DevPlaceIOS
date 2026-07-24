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
    
    var feed: Feed?
    
    func loadFeed(api: DevPlaceApi) async throws {
        AppState.shared.feed = try await api.feed()
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
    
    func updatePostVoteInFeed(postId: String, vote: Vote, count: Int) {
        guard let currentFeed = feed else { return }
        guard currentFeed.posts.contains(where: { $0.data.id == postId }) else { return }
        let updatedPosts = currentFeed.posts.map { post -> Post in
            guard post.data.id == postId else { return post }
            return Post(
                data: Post.Data(
                    id: post.data.id,
                    title: post.data.title,
                    topic: post.data.topic,
                    content: post.data.content,
                    slug: post.data.slug,
                    userId: post.data.userId,
                    stars: count,
                    image: post.data.image,
                    createdAt: post.data.createdAt,
                    updatedAt: post.data.updatedAt,
                ),
                author: post.author,
                myVote: vote,
                commentCount: post.commentCount,
                recentComments: post.recentComments,
                bookmarked: post.bookmarked,
                attachments: post.attachments,
                poll: post.poll,
            )
        }
        feed = Feed(
            posts: updatedPosts,
            currentTab: currentFeed.currentTab,
            currentTopic: currentFeed.currentTopic,
            search: currentFeed.search,
            nextCursor: currentFeed.nextCursor,
            totalMembers: currentFeed.totalMembers,
            postsToday: currentFeed.postsToday,
            totalProjects: currentFeed.totalProjects,
            totalGists: currentFeed.totalGists,
            topAuthors: currentFeed.topAuthors,
        )
    }
    
    func clear() {
        feed = nil
    }
}
