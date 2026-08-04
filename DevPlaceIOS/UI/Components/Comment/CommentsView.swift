import SwiftUI
import DevPlaceSwiftSDK

struct CommentsView: View {
    let comments: [Comment]
    var baseIndentationLevel: Int = 0
    var linksToProfile: Bool = true
    var maxAttachments: Int? = nil
    var onSingleTapComment: ((Comment) -> Void)? = nil
    var onDoubleTapComment: ((Comment) -> Void)? = nil
    var onReactComment: ((Comment, String) -> Void)? = nil
    var onDeleteComment: ((Comment) -> Void)? = nil
    var onEditComment: ((Comment, String) -> Void)? = nil
    var replyingCommentId: String? = nil
    var onReplyComment: ((Comment) -> Void)? = nil
    var replyText: Binding<String> = .constant("")
    var replyAttachments: [UploadResponse] = []
    var onReplyAttachmentsChange: (([UploadResponse]) -> Void)? = nil
    var onSubmitReply: ((Comment, String) -> Void)? = nil
    var onCancelReply: (() -> Void)? = nil
    var editingCommentId: Binding<String?> = .constant(nil)
    var pendingEditQuote: String? = nil
    var onConsumeEditQuote: (() -> Void)? = nil
    var showsDividers: Bool = false
    var showsLeadingDivider: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(comments.indented(startingAt: baseIndentationLevel).enumerated()), id: \.element.id) { index, item in
                CommentView(
                    comment: item.comment,
                    indentationLevel: item.level,
                    linksToProfile: linksToProfile,
                    maxAttachments: maxAttachments,
                    onSingleTap: onSingleTapComment.map { handler in { handler(item.comment) } },
                    onDoubleTap: onDoubleTapComment.map { handler in { handler(item.comment) } },
                    onReact: onReactComment.map { handler in { emoji in handler(item.comment, emoji) } },
                    onDelete: deleteAction(for: item.comment),
                    onSubmitEdit: editAction(for: item.comment),
                    onReply: onReplyComment.map { handler in { handler(item.comment) } },
                    isReplying: replyingCommentId == item.comment.id,
                    replyText: replyText,
                    replyAttachments: replyAttachments,
                    onReplyAttachmentsChange: onReplyAttachmentsChange,
                    onSubmitReply: onSubmitReply.map { handler in { content in handler(item.comment, content) } },
                    onCancelReply: onCancelReply,
                    editingCommentId: editingCommentId,
                    pendingEditQuote: pendingEditQuote,
                    onConsumeEditQuote: onConsumeEditQuote,
                    showsTopDivider: showsDividers && (index > 0 || showsLeadingDivider),
                )
            }
        }
    }

    private func deleteAction(for comment: Comment) -> (() -> Void)? {
        guard let onDeleteComment, AppState.shared.isCurrentUser(id: comment.data.userId) else {
            return nil
        }
        return { onDeleteComment(comment) }
    }

    private func editAction(for comment: Comment) -> ((String) -> Void)? {
        guard let onEditComment, AppState.shared.isCurrentUser(id: comment.data.userId) else {
            return nil
        }
        return { content in onEditComment(comment, content) }
    }
}

private struct IndentedComment: Identifiable {
    let comment: Comment
    let level: Int
    
    var id: String { comment.id }
}

private extension Array where Element == Comment {
    func indented(startingAt level: Int = 0) -> [IndentedComment] {
        flatMap { comment in
            [IndentedComment(comment: comment, level: level)] + comment.children.indented(startingAt: level + 1)
        }
    }
}

#Preview {
    ScrollView {
        CommentsView(comments: .mock)
    }
    .background {
        Color.BG_1.ignoresSafeArea()
    }
    .environment(\.api, .mock)
}
