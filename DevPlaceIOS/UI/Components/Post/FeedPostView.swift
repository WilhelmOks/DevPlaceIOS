import SwiftUI
import DevPlaceSwiftSDK

struct FeedPostView: View {
    let post: Post
    var onSelect: ((String, String?) -> Void)? = nil

    let appSettings = AppSettingsStore.shared
    @Environment(\.api) var api

    @Binding var activeReplyTargetId: String?
    @Binding var editingCommentId: String?
    var pendingEditQuote: String? = nil
    var onConsumeEditQuote: (() -> Void)? = nil
    
    @State private var isEditingPost = false
    @State private var replyAttachments: [UploadResponse] = []
    
    private static let replyAnimation: Animation = .smooth(duration: 0.28)
    
    private var replyDraft: Binding<String> {
        Binding(
            get: { appSettings.draftReplyMessage },
            set: { appSettings.draftReplyMessage = $0 },
        )
    }
    
    private var isReplyingToPost: Bool {
        activeReplyTargetId == post.data.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hLine()
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                PostHeaderView(author: post.author, date: post.data.createdAt, linksToProfile: false)
                
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
                    onReply: { beginReplyToPost() },
                    isReplying: isReplyingToPost,
                    onEdit: AppState.shared.isCurrentUser(id: post.data.userId)
                        ? { isEditingPost = true }
                        : nil,
                    onDelete: AppState.shared.isCurrentUser(id: post.data.userId)
                        ? { Task { await handleDeletePost() } }
                        : nil,
                )
                
                if isReplyingToPost {
                    CommentEditorView(
                        text: replyDraft,
                        initialLineCount: 3,
                        focusOnAppear: true,
                        attachments: replyAttachments,
                        onAttachmentsChange: { replyAttachments = $0 },
                        onCancel: { cancelReply() },
                        onSubmit: { content in submitReplyToPost(content: content) },
                    )
                    .transition(.opacity)
                }
            }
            .padding(.horizontal)
            
            if appSettings.showFeedComments {
                CommentsView(
                    comments: post.recentComments,
                    baseIndentationLevel: 1,
                    linksToProfile: false,
                    maxAttachments: appSettings.showFeedAttachments ? 1 : 0,
                    onSingleTapComment: { comment in navigateToPost(scrollToCommentId: comment.id) },
                    onDoubleTapComment: { comment in Task { await handleDoubleTapComment(comment) } },
                    onReactComment: { comment, emoji in Task { await handleReactComment(comment, emoji: emoji) } },
                    onDeleteComment: { comment in Task { await handleDeleteComment(comment) } },
                    onEditComment: { comment, content in Task { await handleEditComment(comment, content: content) } },
                    replyingCommentId: activeReplyTargetId,
                    onReplyComment: { comment in beginReplyToComment(comment) },
                    replyText: replyDraft,
                    replyAttachments: replyAttachments,
                    onReplyAttachmentsChange: { replyAttachments = $0 },
                    onSubmitReply: { comment, content in submitReplyToComment(comment, content: content) },
                    onCancelReply: { cancelReply() },
                    editingCommentId: $editingCommentId,
                    pendingEditQuote: pendingEditQuote,
                    onConsumeEditQuote: onConsumeEditQuote,
                    showsDividers: true,
                    showsLeadingDivider: true,
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
        .onTapGesture(count: 2) { if activeReplyTargetId == nil { Task { await handleDoubleTapPost() } } }
        .onTapGesture { if activeReplyTargetId == nil { navigateToPost() } }
        .fullScreenCover(isPresented: $isEditingPost) {
            NavigationStack {
                CreatePostView(mode: .edit(post)) {
                    Task { await handleReloadFeed() }
                }
            }
        }
    }
    
    @ViewBuilder private func hLine() -> some View {
        Color.FG_2.frame(height: 1).opacity(0.3)
    }
    
    private func navigateToPost(scrollToCommentId: String? = nil) {
        guard let slug = post.data.slug else { return }
        onSelect?(slug, scrollToCommentId)
    }
    
    private func beginReplyToPost() {
        discardReplyAttachments()
        withAnimation(Self.replyAnimation) {
            activeReplyTargetId = post.data.id
        }
    }
    
    private func beginReplyToComment(_ comment: Comment) {
        discardReplyAttachments()
        withAnimation(Self.replyAnimation) {
            activeReplyTargetId = comment.id
        }
    }
    
    private func cancelReply() {
        discardReplyAttachments()
        withAnimation(Self.replyAnimation) {
            activeReplyTargetId = nil
        }
    }
    
    private func discardReplyAttachments() {
        let unsubmitted = replyAttachments
        replyAttachments = []
        guard !unsubmitted.isEmpty else { return }
        Task {
            for attachment in unsubmitted {
                do {
                    try await api.deleteAttachment(uid: attachment.id)
                } catch {
                    dlog("Failed to delete unsubmitted comment attachment \(attachment.id): \(error)")
                }
            }
        }
    }
    
    private func submitReplyToPost(content: String) {
        let attachments = replyAttachments
        replyAttachments = []
        withAnimation(Self.replyAnimation) {
            activeReplyTargetId = nil
        }
        Task {
            if await createComment(targetType: .post, targetId: post.data.id, parentId: nil, content: content, attachments: attachments) {
                appSettings.draftReplyMessage = ""
            }
        }
    }
    
    private func submitReplyToComment(_ comment: Comment, content: String) {
        let attachments = replyAttachments
        replyAttachments = []
        withAnimation(Self.replyAnimation) {
            activeReplyTargetId = nil
        }
        Task {
            let targetType = TargetType(rawValue: comment.data.targetType) ?? .post
            if await createComment(targetType: targetType, targetId: comment.data.targetId, parentId: comment.data.id, content: content, attachments: attachments) {
                appSettings.draftReplyMessage = ""
            }
        }
    }
    
    private func createComment(targetType: TargetType, targetId: String, parentId: String?, content: String, attachments: [UploadResponse]) async -> Bool {
        do {
            try await api.createComment(targetType: targetType, targetId: targetId, content: content, parentId: parentId, attachments: attachments)
            try await AppState.shared.loadFeed(api: api)
            return true
        } catch {
            dlog("Create comment failed: \(error)")
            return false
        }
    }
    
    private func handleDoubleTapPost() async {
        guard !AppState.shared.isCurrentUser(id: post.data.userId) else {
            isEditingPost = true
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

    private func handleReloadFeed() async {
        do {
            try await AppState.shared.loadFeed(api: api)
        } catch {
            dlog("Reload feed failed: \(error)")
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
    @Previewable @State var activeReplyTargetId: String?
    @Previewable @State var editingCommentId: String?
    ScrollView {
        LazyVStack(spacing: 16) {
            let posts = [Post].mock
            ForEach(posts, id: \.id) { post in
                FeedPostView(
                    post: post,
                    activeReplyTargetId: $activeReplyTargetId,
                    editingCommentId: $editingCommentId,
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
    .background {
        Color.BG_2.ignoresSafeArea()
    }
    .environment(\.api, .mock)
}
