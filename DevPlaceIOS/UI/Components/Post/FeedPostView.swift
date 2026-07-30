import SwiftUI
import DevPlaceSwiftSDK

struct FeedPostView: View {
    let post: Post
    var onSelect: ((String, String?) -> Void)? = nil
    
    let appSettings = AppSettingsStore.shared
    @Environment(\.api) var api
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hLine()
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                PostHeaderView(author: post.author, date: post.data.createdAt)
                
                PostContentView(topic: post.data.topic, title: post.data.title, content: post.data.content)
                
                if let poll = post.poll {
                    PollView(poll: poll)
                }
                
                if appSettings.showFeedAttachments, let attachment = post.attachments.first {
                    AttachmentViewer(attachment: attachment)
                }
                
                PostFooterView(
                    targetId: post.data.id,
                    starCount: post.data.stars,
                    currentVote: post.myVote,
                    reactions: post.reactions,
                    onReact: { emoji in
                        Task { await handleReactPost(emoji: emoji) }
                    },
                    onDelete: AppState.shared.isCurrentUser(id: post.data.userId)
                        ? { Task { await handleDeletePost() } }
                        : nil,
                )
            }
            .padding(.horizontal)
            
            if appSettings.showFeedComments {
                CommentsView(
                    comments: post.recentComments,
                    baseIndentationLevel: 1,
                    onSingleTapComment: { comment in navigateToPost(scrollToCommentId: comment.id) },
                    onDoubleTapComment: { comment in Task { await handleDoubleTapComment(comment) } },
                    onReactComment: { comment, emoji in Task { await handleReactComment(comment, emoji: emoji) } },
                    onDeleteComment: { comment in Task { await handleDeleteComment(comment) } },
                    onEditComment: { comment, content in Task { await handleEditComment(comment, content: content) } },
                )
                .padding(.top, 8)
            }
            
            hLine()
                .padding(.top, 8)
        }
        .foregroundStyle(Color.FG_1)
        .background {
            Color.BG_1
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { Task { await handleDoubleTapPost() } }
        .onTapGesture { navigateToPost() }
    }
    
    @ViewBuilder private func hLine() -> some View {
        Color.FG_2.frame(height: 1).opacity(0.3)
    }
    
    private func navigateToPost(scrollToCommentId: String? = nil) {
        guard let slug = post.data.slug else { return }
        onSelect?(slug, scrollToCommentId)
    }
    
    private func handleDoubleTapPost() async {
        guard !AppState.shared.isCurrentUser(id: post.data.userId) else {
            // Editing isn't possible from the feed, so a double tap on your own post does nothing.
            return
        }
        await AppState.shared.performVoteToggle(
            targetType: .post,
            targetId: post.data.id,
            currentVote: post.myVote,
            api: api,
        ) { newVote in
            let newCount = post.data.stars + newVote.value - post.myVote.value
            AppState.shared.updatePostVoteInFeed(postId: post.data.id, vote: newVote, count: newCount)
        }
    }
    
    private func handleDoubleTapComment(_ comment: Comment) async {
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
            AppState.shared.updateCommentVoteInFeed(commentId: comment.data.id, vote: newVote)
        }
    }
    
    private func handleDeletePost() async {
        guard let slug = post.data.slug else { return }
        do {
            try await api.deletePost(slug: slug)
            try await AppState.shared.loadFeed(api: api)
        } catch {
            dlog("Delete post failed: \(error)")
        }
    }
    
    private func handleDeleteComment(_ comment: Comment) async {
        do {
            try await api.deleteComment(uid: comment.data.id)
            try await AppState.shared.loadFeed(api: api)
        } catch {
            dlog("Delete comment failed: \(error)")
        }
    }

    private func handleEditComment(_ comment: Comment, content: String) async {
        do {
            try await api.editComment(uid: comment.data.id, content: content)
            try await AppState.shared.loadFeed(api: api)
        } catch {
            dlog("Edit comment failed: \(error)")
        }
    }

    private func handleReactPost(emoji: String) async {
        await AppState.shared.performReactionToggle(
            targetType: .post,
            targetId: post.data.id,
            emoji: emoji,
            api: api,
        ) {
            AppState.shared.updatePostReactionInFeed(postId: post.data.id, emoji: emoji)
        }
    }
    
    private func handleReactComment(_ comment: Comment, emoji: String) async {
        await AppState.shared.performReactionToggle(
            targetType: .comment,
            targetId: comment.data.id,
            emoji: emoji,
            api: api,
        ) {
            AppState.shared.updateCommentReactionInFeed(commentId: comment.data.id, emoji: emoji)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 16) {
            let posts = [Post].mock
            ForEach(posts, id: \.id) { post in
                FeedPostView(post: post)
            }
        }
        .frame(maxWidth: .infinity)
    }
    .background {
        Color.BG_2.ignoresSafeArea()
    }
    .environment(\.api, .mock)
}
