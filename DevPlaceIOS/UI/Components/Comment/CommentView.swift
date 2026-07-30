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
    var onReply: (() -> Void)? = nil
    var isReplying: Bool = false
    var replyText: Binding<String> = .constant("")
    var onSubmitReply: ((String) -> Void)? = nil
    var onCancelReply: (() -> Void)? = nil

    @State private var isConfirmingDelete = false
    @State private var isEditing = false
    @State private var editedText = ""
    @State private var contentHeight: CGFloat = 0

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
                    .transition(.opacity)
            } else {
                PostContentView(topic: nil, title: nil, content: comment.data.content)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newHeight in
                        contentHeight = newHeight
                    }
                    .transition(.opacity)
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

                if !isEditing {
                    HStack(spacing: 24) {
                        if let onReply, !isReplying {
                            replyButton(onReply: onReply)
                        }

                        if canEdit {
                            editButton()
                        }

                        if onDelete != nil {
                            deleteButton()
                        }
                    }
                    .transition(.opacity)
                }
            }

            if isReplying && !isEditing {
                ReplyEditorView(
                    text: replyText,
                    onCancel: { onCancelReply?() },
                    onSubmit: { content in onSubmitReply?(content) },
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { handleDoubleTap() }
        .onTapGesture { if !isEditing { onSingleTap?() } }
    }

    private static let editModeAnimation: Animation = .smooth(duration: 0.28)

    private func handleDoubleTap() {
        guard !isEditing else { return }
        if canEdit {
            beginEditing()
        } else {
            onDoubleTap?()
        }
    }

    @ViewBuilder private func editor() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            DevPlaceTextEditor(
                text: $editedText,
                placeholder: "Edit your comment…",
                animatesHeightChanges: true,
                initialHeight: contentHeight > 0 ? contentHeight : nil,
            )

            HStack(alignment: .top, spacing: 12) {
                CharacterCounterView(
                    text: editedText,
                    minCount: DevPlaceConstants.minCommentContentLength,
                    maxCount: DevPlaceConstants.maxCommentContentLength,
                )
                .padding(.horizontal, 11)

                Spacer(minLength: 0)

                HStack(spacing: 24) {
                    Button {
                        withAnimation(Self.editModeAnimation) { isEditing = false }
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.FG_2)

                    Button {
                        onSubmitEdit?(editedText)
                        withAnimation(Self.editModeAnimation) { isEditing = false }
                    } label: {
                        Label("Submit", systemImage: "checkmark")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .disabled(!canSubmitEdit)
                }
                .padding(.horizontal, 11)
            }
        }
    }

    private var canSubmitEdit: Bool {
        let count = TextCharacterCounter.numberOfCharacters(editedText)
        return count >= DevPlaceConstants.minCommentContentLength
            && count <= DevPlaceConstants.maxCommentContentLength
    }

    @ViewBuilder private func replyButton(onReply: @escaping () -> Void) -> some View {
        Button {
            onReply()
        } label: {
            Label("Reply to comment", systemImage: "arrowshape.turn.up.left")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
    }

    @ViewBuilder private func editButton() -> some View {
        Button {
            beginEditing()
        } label: {
            Label("Edit comment", systemImage: "pencil")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
    }

    private var canEdit: Bool {
        onSubmitEdit != nil
    }

    private func beginEditing() {
        editedText = comment.data.content
        withAnimation(Self.editModeAnimation) { isEditing = true }
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
