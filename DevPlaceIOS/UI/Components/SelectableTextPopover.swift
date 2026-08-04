import SwiftUI
import UIKit

extension View {
    func selectableTextPopover(_ text: String) -> some View {
        modifier(SelectableTextPopoverModifier(text: text))
    }
}

private struct SelectableTextPopoverModifier: ViewModifier {
    let text: String

    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                isPresented = true
            }
            .popover(isPresented: $isPresented) {
                SelectableTextPopoverContent(text: text)
                    .presentationCompactAdaptation(.popover)
            }
    }
}

private struct SelectableTextPopoverContent: View {
    let text: String

    @State private var selection = TextSelectionController()

    @Environment(\.quoteComposer) private var quoteComposer
    @Environment(\.dismiss) private var dismiss

    private let maxContentSize = CGSize(width: 360, height: 400)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SelectableRawTextView(
                text: text,
                maxSize: maxContentSize,
                selection: selection,
            )

            footer()
        }
        .padding(20)
    }

    @ViewBuilder private func footer() -> some View {
        HStack {
            HStack(spacing: 16) {
                Button {
                    selection.selectFirstWord()
                } label: {
                    Label("Select first word", systemImage: "selection.pin.in.out")
                        .labelStyle(.iconOnly)
                }

                Button {
                    selection.selectAll()
                } label: {
                    Label("Select all text", systemImage: "textformat.characters.arrow.left.and.right")
                        .labelStyle(.iconOnly)
                }
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    selection.copySelection()
                    dismiss()
                } label: {
                    Label("Copy to clipboard", systemImage: "document.on.clipboard")
                        .labelStyle(.iconOnly)
                }

                if quoteComposer.isActive {
                    Button {
                        quoteComposer.insert("> " + selection.selectedText + "\n\n")
                        dismiss()
                    } label: {
                        Label("Insert as quote", systemImage: "text.quote")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .font(.footnote)
        .foregroundStyle(Color.FG_2)
        .buttonStyle(.plain)
    }
}

@MainActor private final class TextSelectionController {
    weak var textView: UITextView?

    var selectedText: String {
        guard let textView else { return "" }
        if let range = textView.selectedTextRange, !range.isEmpty {
            return textView.text(in: range) ?? ""
        }
        return textView.text ?? ""
    }

    func selectFirstWord() {
        guard let textView else { return }
        textView.becomeFirstResponder()
        let content = textView.text as NSString? ?? ""
        let wordRange = content.range(of: "\\S+", options: .regularExpression)
        guard wordRange.location != NSNotFound,
              let start = textView.position(from: textView.beginningOfDocument, offset: wordRange.location),
              let end = textView.position(from: start, offset: wordRange.length) else { return }
        textView.selectedTextRange = textView.textRange(from: start, to: end)
    }

    func selectAll() {
        guard let textView else { return }
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(
            from: textView.beginningOfDocument,
            to: textView.endOfDocument,
        )
    }

    func copySelection() {
        UIPasteboard.general.string = selectedText
    }
}

private struct SelectableRawTextView: UIViewRepresentable {
    let text: String
    let maxSize: CGSize
    let selection: TextSelectionController

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .FG_1
        textView.text = text
        selection.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        selection.textView = uiView
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let availableWidth = min(proposal.width ?? maxSize.width, maxSize.width)
        let ideal = uiView.sizeThatFits(
            CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude,
            )
        )
        let width = min(ideal.width, availableWidth)
        let fittedHeight = uiView.sizeThatFits(
            CGSize(
                width: width,
                height: CGFloat.greatestFiniteMagnitude,
            )
        ).height
        let availableHeight = min(proposal.height ?? maxSize.height, maxSize.height)
        return CGSize(
            width: width,
            height: min(fittedHeight, availableHeight),
        )
    }
}

#Preview {
    Text("Long press me")
        .padding()
        .selectableTextPopover("The quick brown fox jumps over the lazy dog. Select any part of this raw text and copy it to the clipboard.")
        .screenStyle(bgColor: .BG_2)
}
