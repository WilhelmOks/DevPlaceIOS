import SwiftUI
import DevPlaceSwiftSDK

struct PostView: View {
    let slug: String
    var scrollToCommentId: String? = nil
    
    @Environment(\.api) var api
    
    var body: some View {
        PostViewContent(viewModel: .init(slug: slug, api: api), scrollToCommentId: scrollToCommentId)
    }
}

private struct PostViewContent: View {
    @State var viewModel: PostView.ViewModel
    var scrollToCommentId: String? = nil
    
    @State private var isEditingPost = false
    @State private var activeReply: ReplyAnchor?
    @State private var replyAttachments: [UploadResponse] = []
    @State private var editingCommentId: String?
    @State private var pendingEditQuote: String?
    
    private let appSettings = AppSettingsStore.shared
    
    @Environment(\.dismiss) private var dismiss
    
    private enum ReplyAnchor: Equatable {
        case post
        case comment(String)
        case bottom
    }
    
    private static let replyAnimation: Animation = .smooth(duration: 0.28)
    
    private var replyDraft: Binding<String> {
        Binding(
            get: { appSettings.draftReplyMessage },
            set: { appSettings.draftReplyMessage = $0 },
        )
    }

    private var isComposerActive: Bool {
        activeReply != nil || editingCommentId != nil
    }

    private func insertQuote(_ quote: String) {
        if editingCommentId != nil {
            pendingEditQuote = quote
        } else if activeReply != nil {
            appSettings.draftReplyMessage += quote
        }
    }
    
    var body: some View {
        content()
            .environment(
                \.quoteComposer,
                QuoteComposer(isActive: isComposerActive, insert: insertQuote),
            )
            .screenStyle(bgColor: .BG_1)
            .navigationTitle(Text(viewModel.navigationTitle))
            .navigationBarTitleDisplayMode(.inline)
            .alert($viewModel.alertMessage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    reloadToolbarItem()
                }
            }
            .fullScreenCover(isPresented: $isEditingPost) {
                if let post = viewModel.editablePost {
                    NavigationStack {
                        CreatePostView(mode: .edit(post)) {
                            Task { await viewModel.reload() }
                        }
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .onDisappear {
                discardReplyAttachments()
            }
    }
    
    @ViewBuilder private func content() -> some View {
        if let postDetail = viewModel.postDetail {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        postBody(postDetail)
                        
                        commentsSection(postDetail)
                        
                        bottomCommentSection(postDetail)
                    }
                }
                .onAppear {
                    scrollToTargetComment(using: proxy)
                }
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func scrollToTargetComment(using proxy: ScrollViewProxy) {
        guard let scrollToCommentId else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation {
                proxy.scrollTo(scrollToCommentId, anchor: .top)
            }
        }
    }
    
    private func beginReply(_ anchor: ReplyAnchor) {
        discardReplyAttachments()
        withAnimation(Self.replyAnimation) {
            activeReply = anchor
        }
    }
    
    private func cancelReply() {
        discardReplyAttachments()
        withAnimation(Self.replyAnimation) {
            activeReply = nil
        }
    }
    
    private func discardReplyAttachments() {
        let unsubmitted = replyAttachments
        replyAttachments = []
        guard !unsubmitted.isEmpty else { return }
        Task {
            await viewModel.deleteUnsubmittedAttachments(unsubmitted)
        }
    }
    
    private func submitReplyToPost(_ detail: PostDetail, content: String) {
        let attachments = replyAttachments
        replyAttachments = []
        withAnimation(Self.replyAnimation) {
            activeReply = nil
        }
        Task {
            if await viewModel.submitComment(targetType: .post, targetId: detail.post.id, parentId: nil, content: content, attachments: attachments) {
                appSettings.draftReplyMessage = ""
            }
        }
    }
    
    private func submitReplyToComment(_ comment: Comment, content: String) {
        let attachments = replyAttachments
        replyAttachments = []
        withAnimation(Self.replyAnimation) {
            activeReply = nil
        }
        Task {
            let targetType = TargetType(rawValue: comment.data.targetType) ?? .post
            if await viewModel.submitComment(targetType: targetType, targetId: comment.data.targetId, parentId: comment.data.id, content: content, attachments: attachments) {
                appSettings.draftReplyMessage = ""
            }
        }
    }
    
    private var replyingCommentId: String? {
        if case .comment(let id) = activeReply {
            return id
        }
        return nil
    }
    
    @ViewBuilder private func postBody(_ detail: PostDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PostHeaderView(
                author: detail.author,
                date: detail.post.createdAt,
            )
            
            PostContentView(topic: detail.post.topic, title: detail.post.title, content: detail.post.content)
            
            if let poll = detail.poll {
                PollView(poll: poll)
            }
            
            ForEach(detail.attachments, id: \.id) { attachment in
                AttachmentViewer(attachment: attachment)
            }
            
            PostFooterView(
                targetId: detail.post.id,
                starCount: detail.starCount,
                currentVote: detail.myVote,
                reactions: detail.reactions,
                onReact: { emoji in
                    Task { await viewModel.reactToPost(emoji: emoji) }
                },
                onReply: { beginReply(.post) },
                isReplying: activeReply == .post,
                onEdit: AppState.shared.isCurrentUser(id: detail.post.userId)
                    ? { isEditingPost = true }
                    : nil,
                onDelete: AppState.shared.isCurrentUser(id: detail.post.userId)
                    ? {
                        Task {
                            if await viewModel.deletePost() {
                                dismiss()
                            }
                        }
                    }
                    : nil,
            )
            
            if activeReply == .post {
                CommentEditorView(
                    text: replyDraft,
                    initialLineCount: 3,
                    focusOnAppear: true,
                    attachments: replyAttachments,
                    onAttachmentsChange: { replyAttachments = $0 },
                    onCancel: { cancelReply() },
                    onSubmit: { content in submitReplyToPost(detail, content: content) },
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .foregroundStyle(Color.FG_1)
        .background {
            Color.BG_1
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            if AppState.shared.isCurrentUser(id: detail.post.userId) {
                isEditingPost = true
            } else {
                Task { await viewModel.upvoteForeignPost() }
            }
        }
    }
    
    @ViewBuilder private func commentsSection(_ detail: PostDetail) -> some View {
        if !detail.comments.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Comments")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top)
                
                CommentsView(
                    comments: detail.comments,
                    onDoubleTapComment: { comment in
                        Task { await viewModel.doubleTapComment(comment) }
                    },
                    onReactComment: { comment, emoji in
                        Task { await viewModel.reactToComment(comment, emoji: emoji) }
                    },
                    onDeleteComment: { comment in
                        Task { await viewModel.deleteComment(comment) }
                    },
                    onEditComment: { comment, content in
                        Task { await viewModel.editComment(comment, content: content) }
                    },
                    replyingCommentId: replyingCommentId,
                    onReplyComment: { comment in beginReply(.comment(comment.id)) },
                    replyText: replyDraft,
                    replyAttachments: replyAttachments,
                    onReplyAttachmentsChange: { replyAttachments = $0 },
                    onSubmitReply: { comment, content in submitReplyToComment(comment, content: content) },
                    onCancelReply: { cancelReply() },
                    editingCommentId: $editingCommentId,
                    pendingEditQuote: pendingEditQuote,
                    onConsumeEditQuote: { pendingEditQuote = nil },
                    showsDividers: true,
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder private func bottomCommentSection(_ detail: PostDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if activeReply == .bottom {
                CommentEditorView(
                    text: replyDraft,
                    placeholder: "Write a comment…",
                    initialLineCount: 3,
                    focusOnAppear: true,
                    attachments: replyAttachments,
                    onAttachmentsChange: { replyAttachments = $0 },
                    onCancel: { cancelReply() },
                    onSubmit: { content in submitReplyToPost(detail, content: content) },
                )
                .transition(.opacity)
            } else {
                Button {
                    beginReply(.bottom)
                } label: {
                    Label("Comment", systemImage: "bubble.left")
                }
                .buttonStyle(.form)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    @ViewBuilder private func reloadToolbarItem() -> some View {
        if viewModel.isReloading {
            ProgressView()
        } else {
            Button {
                Task { await viewModel.reload() }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostView(slug: "mock-slug")
    }
    .environment(\.api, .mock)
}
