import SwiftUI
import DevPlaceSwiftSDK

struct CommentView: View {
    let comment: Comment
    var indentationLevel: Int = 0
    var onSingleTap: (() -> Void)? = nil
    var onDoubleTap: (() -> Void)? = nil
    
    private let maxIndentationLevel = 3
    private let indentWidth: CGFloat = 16
    private let lineOpacity: Double = 0.3
    
    private var effectiveLevel: Int {
        min(indentationLevel, maxIndentationLevel)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if effectiveLevel > 0 {
                ForEach(1...effectiveLevel, id: \.self) { level in
                    guideLine(dashed: level == maxIndentationLevel)
                        .frame(width: indentWidth)
                        .frame(maxHeight: .infinity)
                }
            }
            
            commentBody()
        }
        .foregroundStyle(Color.FG_1)
    }
    
    @ViewBuilder private func commentBody() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PostHeaderView(author: comment.author, date: comment.data.createdAt)
            
            PostContentView(topic: nil, title: nil, content: comment.data.content)
            
            ForEach(comment.attachments, id: \.id) { attachment in
                AttachmentViewer(attachment: attachment)
            }
            
            VoteView(
                targetType: .comment,
                targetId: comment.data.id,
                count: comment.voteCount,
                currentVote: comment.myVote,
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { onDoubleTap?() }
        .onTapGesture { onSingleTap?() }
    }
    
    @ViewBuilder private func guideLine(dashed: Bool) -> some View {
        VerticalLine()
            .stroke(
                Color.FG_2.opacity(lineOpacity),
                style: StrokeStyle(lineWidth: 1, dash: dashed ? [3, 3] : []),
            )
    }
}

private struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                let comments = [Comment].mock
                CommentView(comment: comments[0], indentationLevel: 0)
                CommentView(comment: comments[1], indentationLevel: 1)
                CommentView(comment: comments[0], indentationLevel: 2)
                CommentView(comment: comments[1], indentationLevel: 3)
                CommentView(comment: comments[0], indentationLevel: 4)
            }
            .frame(maxWidth: .infinity)
        }
        .background {
            Color.BG_1.ignoresSafeArea()
        }
        .environment(\.api, .mock)
    }
}
