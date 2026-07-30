import SwiftUI
import DevPlaceSwiftSDK

struct CommentView: View {
    let comment: Comment
    var indentationLevel: Int = 0
    var onSingleTap: (() -> Void)? = nil
    var onDoubleTap: (() -> Void)? = nil
    var onReact: ((String) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onSubmitEdit: ((String) -> Void)? = nil

    @State private var isConfirmingDelete = false
    @State private var isEditing = false
    @State private var editedText = ""

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

            if isEditing {
                editor()
            } else {
                PostContentView(topic: nil, title: nil, content: comment.data.content)
            }

            ForEach(comment.attachments, id: \.id) { attachment in
                AttachmentViewer(attachment: attachment)
            }

            HStack(spacing: 12) {
                VoteView(
                    targetType: .comment,
                    targetId: comment.data.id,
                    count: comment.voteCount,
                    currentVote: comment.myVote,
                )

                ReactionsBar(reactions: comment.reactions, onReact: onReact ?? { _ in })

                Spacer(minLength: 0)

                if onSubmitEdit != nil, !isEditing {
                    editButton()
                }

                if onDelete != nil {
                    deleteButton()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { if !isEditing { onDoubleTap?() } }
        .onTapGesture { if !isEditing { onSingleTap?() } }
    }

    @ViewBuilder private func editor() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            DevPlaceTextEditor(
                text: $editedText,
                placeholder: "Edit your comment…",
            )

            CharacterCounterView(
                text: editedText,
                minCount: DevPlaceConstants.minCommentContentLength,
                maxCount: DevPlaceConstants.maxCommentContentLength,
            )
            .padding(.horizontal, 11)

            HStack(spacing: 12) {
                Spacer(minLength: 0)

                Button("Cancel") {
                    isEditing = false
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.FG_2)

                Button {
                    onSubmitEdit?(editedText)
                    isEditing = false
                } label: {
                    Label("Submit", systemImage: "checkmark")
                }
                .disabled(!canSubmitEdit)
            }
        }
    }

    private var canSubmitEdit: Bool {
        let count = TextCharacterCounter.numberOfCharacters(editedText)
        return count >= DevPlaceConstants.minCommentContentLength
            && count <= DevPlaceConstants.maxCommentContentLength
    }

    @ViewBuilder private func editButton() -> some View {
        Button {
            editedText = comment.data.content
            isEditing = true
        } label: {
            Label("Edit comment", systemImage: "pencil")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
    }

    @ViewBuilder private func deleteButton() -> some View {
        Button {
            isConfirmingDelete = true
        } label: {
            Label("Delete comment", systemImage: "trash")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
        .confirmationDialog(
            "Delete this comment?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible,
        ) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) {}
        }
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
