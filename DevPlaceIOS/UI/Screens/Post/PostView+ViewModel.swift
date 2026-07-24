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
        
        func doubleTapPost() async {
            guard let detail = postDetail else { return }
            guard !AppState.shared.isCurrentUser(id: detail.post.userId) else {
                // TODO: edit the post (editing own posts is not implemented yet)
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
                // TODO: edit the comment (editing own comments is not implemented yet)
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
    }
}
