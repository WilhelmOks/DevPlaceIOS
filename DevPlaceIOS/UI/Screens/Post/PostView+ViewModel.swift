import Foundation
import Observation
import DevPlaceSwiftSDK

extension PostView {
    @Observable final class ViewModel {
        let slug: String
        let api: DevPlaceApi
        
        var postDetail: PostDetail?
        
        var isReloading = false
        
        var alertMessage: AlertMessage = .none()
        
        init(slug: String, api: DevPlaceApi) {
            self.slug = slug
            self.api = api
        }
        
        var navigationTitle: String {
            postDetail?.post.title ?? "Post"
        }
        
        var editablePost: Post? {
            guard let detail = postDetail else { return nil }
            return Post(
                data: detail.post,
                author: detail.author,
                myVote: detail.myVote,
                commentCount: detail.commentCount,
                recentComments: detail.comments,
                bookmarked: detail.bookmarked,
                attachments: detail.attachments,
                poll: detail.poll,
                reactions: detail.reactions,
            )
        }
        
        func load() async {
            do {
                postDetail = try await api.postDetail(slug: slug)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        func reload() async {
            guard !isReloading else { return }
            isReloading = true
            defer { isReloading = false }
            do {
                postDetail = try await api.postDetail(slug: slug)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        func deletePost() async -> Bool {
            do {
                try await api.deletePost(slug: slug)
                try await AppState.shared.loadFeed(api: api)
                return true
            } catch {
                alertMessage = .presentedError(error)
                return false
            }
        }
        
        func deleteComment(_ comment: Comment) async {
            do {
                try await api.deleteComment(uid: comment.data.id)
                postDetail = try await api.postDetail(slug: slug)
                try await AppState.shared.loadFeed(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func editComment(_ comment: Comment, content: String) async {
            do {
                try await api.editComment(uid: comment.data.id, content: content)
                postDetail = try await api.postDetail(slug: slug)
                try await AppState.shared.loadFeed(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func upvoteForeignPost() async {
            guard let detail = postDetail else { return }
            guard !AppState.shared.isCurrentUser(id: detail.post.userId) else {
                return
            }
            await AppState.shared.performVoteToggle(
                targetType: .post,
                targetId: detail.post.id,
                currentVote: detail.myVote,
                api: api,
            ) { newVote in
                let newCount = detail.starCount + newVote.value - detail.myVote.value
                postDetail = detail.with(myVote: newVote, starCount: newCount)
                AppState.shared.updatePostVoteInFeed(postId: detail.post.id, vote: newVote, count: newCount)
            }
        }
        
        func doubleTapComment(_ comment: Comment) async {
            guard let detail = postDetail else { return }
            guard !AppState.shared.isCurrentUser(id: comment.data.userId) else {
                // A double tap on your own comment begins inline editing in CommentView, so this only votes on others' comments.
                return
            }
            await AppState.shared.performVoteToggle(
                targetType: .comment,
                targetId: comment.data.id,
                currentVote: comment.myVote,
                api: api,
            ) { newVote in
                postDetail = detail.with(comments: detail.comments.updatingVote(commentId: comment.data.id, vote: newVote))
                AppState.shared.updateCommentVoteInFeed(commentId: comment.data.id, vote: newVote)
            }
        }
        
        func reactToPost(emoji: String) async {
            guard let detail = postDetail else { return }
            await AppState.shared.performReactionToggle(
                targetType: .post,
                targetId: detail.post.id,
                emoji: emoji,
                api: api,
            ) {
                guard let current = postDetail else { return }
                postDetail = current.with(reactions: current.reactions.toggling(emoji))
                AppState.shared.updatePostReactionInFeed(postId: detail.post.id, emoji: emoji)
            }
        }
        
        func reactToComment(_ comment: Comment, emoji: String) async {
            guard postDetail != nil else { return }
            await AppState.shared.performReactionToggle(
                targetType: .comment,
                targetId: comment.data.id,
                emoji: emoji,
                api: api,
            ) {
                guard let current = postDetail else { return }
                postDetail = current.with(comments: current.comments.updatingReaction(commentId: comment.data.id, emoji: emoji))
                AppState.shared.updateCommentReactionInFeed(commentId: comment.data.id, emoji: emoji)
            }
        }
    }
}
