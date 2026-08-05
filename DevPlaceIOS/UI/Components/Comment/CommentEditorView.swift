import SwiftUI
import DevPlaceSwiftSDK

struct CommentEditorView: View {
    static let scrollAnchorName = "commentComposerAnchor"

    @Binding var text: String
    var placeholder: String = "Write a reply…"
    var initialLineCount: Int? = nil
    var initialHeight: CGFloat? = nil
    var focusOnAppear: Bool = false
    var attachments: [UploadResponse] = []
    var onAttachmentsChange: (([UploadResponse]) -> Void)? = nil
    var mentionParticipants: [UserSearch.Result] = []
    let onCancel: () -> Void
    let onSubmit: (String) -> Void

    @FocusState private var isFocused: Bool

    private let keyboardGap: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MentionSuggestionsView(
                text: text,
                participants: mentionParticipants,
                onSelect: { suggestion in insertMention(suggestion) },
            )

            DevPlaceTextEditor(
                text: $text,
                placeholder: placeholder,
                initialLineCount: initialLineCount,
                animatesHeightChanges: true,
                initialHeight: initialHeight,
                backgroundColor: .BG_0,
            )
            .focused($isFocused)

            HStack(alignment: .top, spacing: 12) {
                CharacterCounterView(
                    text: text,
                    minCount: DevPlaceConstants.minCommentContentLength,
                    maxCount: DevPlaceConstants.maxCommentContentLength,
                )
                .padding(.horizontal, 11)

                Spacer(minLength: 0)

                HStack(spacing: 24) {
                    if let onAttachmentsChange, attachments.isEmpty {
                        AttachmentUploaderView(
                            isSmall: true,
                            attachments: attachments,
                            onAttachmentsChange: onAttachmentsChange,
                        )
                    }

                    Button {
                        onCancel()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.FG_2)

                    Button {
                        onSubmit(text)
                    } label: {
                        Label("Submit", systemImage: "checkmark")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .disabled(!canSubmit)
                }
                .padding(.horizontal, 11)
            }

            if let onAttachmentsChange, !attachments.isEmpty {
                AttachmentUploaderView(
                    attachments: attachments,
                    onAttachmentsChange: onAttachmentsChange,
                )
            }
        }
        .padding(.bottom, keyboardGap)
        .id(Self.scrollAnchorName)
        .onAppear {
            guard focusOnAppear else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(50))
                isFocused = true
            }
        }
    }

    private var canSubmit: Bool {
        let count = TextCharacterCounter.numberOfCharacters(text)
        return count >= DevPlaceConstants.minCommentContentLength
            && count <= DevPlaceConstants.maxCommentContentLength
    }

    private func insertMention(_ suggestion: UserSearch.Result) {
        guard let token = MentionToken.active(in: text) else {
            return
        }
        text.replaceSubrange(token.range, with: "@\(suggestion.username) ")
    }
}

#Preview {
    @Previewable @State var text = ""
    ScrollView {
        CommentEditorView(
            text: $text,
            initialLineCount: 3,
            focusOnAppear: true,
            onCancel: {},
            onSubmit: { _ in },
        )
        .padding()
    }
    .background {
        Color.BG_1.ignoresSafeArea()
    }
}
