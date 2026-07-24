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
    
    func isCurrentUser(id: String) -> Bool {
        currentUser?.id == id
    }
    
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
    
    func updateCommentVoteInFeed(commentId: String, vote: Vote) {
        guard let currentFeed = feed else { return }
        let updatedPosts = currentFeed.posts.map { post in
            post.replacingRecentComments(post.recentComments.updatingVote(commentId: commentId, vote: vote))
        }
        feed = currentFeed.replacingPosts(updatedPosts)
    }
    
    /// Performs an optimistic upvote toggle: if the current vote is already `.up` it is removed,
    /// otherwise it becomes `.up`. The backend `vote` endpoint toggles, so the selected value sent
    /// is always `.up`. `apply` is called with the new optimistic vote, and again with the previous
    /// vote to revert if the request fails.
    func performVoteToggle(
        targetType: TargetType,
        targetId: String,
        currentVote: Vote,
        api: DevPlaceApi,
        apply: (Vote) -> Void,
    ) async {
        let newVote: Vote = currentVote == .up ? .none : .up
        apply(newVote)
        do {
            try await api.vote(targetType: targetType, targetId: targetId, vote: .up)
        } catch {
            apply(currentVote)
            dlog("Double-tap vote failed: \(error)")
        }
    }
    
    func clear() {
        feed = nil
        currentUser = nil
    }
}
