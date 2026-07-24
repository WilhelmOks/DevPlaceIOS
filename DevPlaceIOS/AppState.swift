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
    
    func updateCommentVoteInFeed(commentId: String, vote: Vote) {
        guard let currentFeed = feed else { return }
        let updatedPosts = currentFeed.posts.map { post in
            post.replacingRecentComments(post.recentComments.updatingVote(commentId: commentId, vote: vote))
        }
        feed = currentFeed.replacingPosts(updatedPosts)
    }
    
    func clear() {
        feed = nil
    }
}

private extension Feed {
    func replacingPosts(_ newPosts: [Post]) -> Feed {
        Feed(
            posts: newPosts,
            currentTab: currentTab,
            currentTopic: currentTopic,
            search: search,
            nextCursor: nextCursor,
            totalMembers: totalMembers,
            postsToday: postsToday,
            totalProjects: totalProjects,
            totalGists: totalGists,
            topAuthors: topAuthors,
        )
    }
}

private extension Post {
    func replacingRecentComments(_ newComments: [Comment]) -> Post {
        Post(
            data: data,
            author: author,
            myVote: myVote,
            commentCount: commentCount,
            recentComments: newComments,
            bookmarked: bookmarked,
            attachments: attachments,
            poll: poll,
        )
    }
}

private extension Array where Element == Comment {
    func updatingVote(commentId: String, vote: Vote) -> [Comment] {
        map { comment in
            let updatedChildren = comment.children.updatingVote(commentId: commentId, vote: vote)
            if comment.data.id == commentId {
                return comment.applyingVote(vote, children: updatedChildren)
            } else {
                return comment.replacingChildren(updatedChildren)
            }
        }
    }
}

private extension Comment {
    func applyingVote(_ newVote: Vote, children: [Comment]) -> Comment {
        var up = votes.up
        var down = votes.down
        switch myVote {
        case .up: up -= 1
        case .down: down -= 1
        case .none: break
        }
        switch newVote {
        case .up: up += 1
        case .down: down += 1
        case .none: break
        }
        return Comment(
            data: data,
            author: author,
            myVote: newVote,
            votes: Comment.Votes(up: up, down: down),
            attachments: attachments,
            children: children,
        )
    }
    
    func replacingChildren(_ newChildren: [Comment]) -> Comment {
        Comment(
            data: data,
            author: author,
            myVote: myVote,
            votes: votes,
            attachments: attachments,
            children: newChildren,
        )
    }
}
