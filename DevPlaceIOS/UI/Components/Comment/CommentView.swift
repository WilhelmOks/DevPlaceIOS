import SwiftUI
import DevPlaceSwiftSDK

struct CommentView: View {
    let comment: Comment
    var indentationLevel: Int = 0
    
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
            
            CommentFooterView(votes: comment.votes, myVote: comment.myVote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
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
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

private struct CommentFooterView: View {
    let votes: Comment.Votes
    let myVote: Int
    
    @ScaledMetric private var scale = 1.0
    
    private let buttonSize = 15.0
    
    private var score: Int {
        votes.up - votes.down
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack(spacing: 10) {
                Button {
                    // TODO: submit a downvote for the comment once comment voting is wired up
                } label: {
                    Image(systemName: myVote == -1 ? "minus.circle.fill" : "minus.circle")
                        .font(.system(size: buttonSize * scale))
                }
                .buttonStyle(.plain)
                .foregroundStyle(myVote == -1 ? Color.accentColor : Color.FG_2)
                
                Text("\(score)")
                    .font(.system(size: 14 * scale))
                    .fontWeight(.semibold)
                    .monospacedDigit()
                
                Button {
                    // TODO: submit an upvote for the comment once comment voting is wired up
                } label: {
                    Image(systemName: myVote == 1 ? "plus.circle.fill" : "plus.circle")
                        .font(.system(size: buttonSize * scale))
                }
                .buttonStyle(.plain)
                .foregroundStyle(myVote == 1 ? Color.accentColor : Color.FG_2)
            }
        }
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
            Color.BG_2.ignoresSafeArea()
        }
        .environment(\.api, .mock)
    }
}
