import SwiftUI
import DevPlaceSwiftSDK

struct CommentsView: View {
    let comments: [Comment]
    var baseIndentationLevel: Int = 0
    var onSingleTapComment: ((Comment) -> Void)? = nil
    var onDoubleTapComment: ((Comment) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(comments.indented(startingAt: baseIndentationLevel)) { item in
                CommentView(
                    comment: item.comment,
                    indentationLevel: item.level,
                    onSingleTap: onSingleTapComment.map { handler in { handler(item.comment) } },
                    onDoubleTap: onDoubleTapComment.map { handler in { handler(item.comment) } },
                )
            }
        }
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
