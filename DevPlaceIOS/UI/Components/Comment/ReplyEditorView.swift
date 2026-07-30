import SwiftUI
import DevPlaceSwiftSDK

struct ReplyEditorView: View {
    @Binding var text: String
    var placeholder: String = "Write a reply…"
    let onCancel: () -> Void
    let onSubmit: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DevPlaceTextEditor(
                text: $text,
                placeholder: placeholder,
                initialLineCount: 3,
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
        }
        .onAppear {
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
}

#Preview {
    @Previewable @State var text = ""
    ScrollView {
        ReplyEditorView(text: $text, onCancel: {}, onSubmit: { _ in })
            .padding()
    }
    .background {
        Color.BG_1.ignoresSafeArea()
    }
}
