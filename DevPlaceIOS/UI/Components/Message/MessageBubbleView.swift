import SwiftUI
import MarkdownUI
import DevPlaceSwiftSDK

struct MessageBubbleView: View {
    let message: Message

    @Environment(\.colorScheme) private var colorScheme

    private let maxBubbleWidth: CGFloat = 320
    private let cornerRadius: CGFloat = 16

    var body: some View {
        HStack(spacing: 0) {
            if message.isMine {
                Spacer(minLength: 40)
            }

            bubble()

            if !message.isMine {
                Spacer(minLength: 40)
            }
        }
    }

    @ViewBuilder private func bubble() -> some View {
        HuggingWidthLayout(maxWidth: maxBubbleWidth) {
            VStack(alignment: bubbleAlignment, spacing: 8) {
                if !message.data.content.isEmpty {
                    Markdown(message.data.content)
                        .markdownTheme(.devPlace)
                        .markdownSoftBreakMode(.lineBreak)
                }

                ForEach(message.attachments, id: \.id) { attachment in
                    AttachmentViewer(attachment: attachment)
                }

                footer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .foregroundStyle(Color.FG_1)
        .background(bubbleColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    @ViewBuilder private func footer() -> some View {
        HStack(spacing: 6) {
            RelativeTimeLabel(date: message.data.createdAt)

            if message.isMine {
                DoubleCheckmark(read: message.data.read)
            }
        }
    }

    private var bubbleAlignment: HorizontalAlignment {
        message.isMine ? .trailing : .leading
    }

    private var bubbleColor: Color {
        guard message.isMine else {
            return .BG_1
        }
        return colorScheme == .dark
            ? Color.accentColor.mix(with: .black, by: 0.55)
            : Color.accentColor.mix(with: .white, by: 0.6)
    }
}

private struct HuggingWidthLayout: Layout {
    let maxWidth: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = min(proposal.replacingUnspecifiedDimensions().width, maxWidth)
        return subviews[0].sizeThatFits(ProposedViewSize(width: width, height: proposal.height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews[0].place(
            at: bounds.origin,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height),
        )
    }
}

private struct DoubleCheckmark: View {
    let read: Bool

    @ScaledMetric private var scale = 1.0

    var body: some View {
        if read {
            ZStack {
                Image(systemName: "checkmark")
                    .offset(x: -3 * scale)
                Image(systemName: "checkmark")
                    .offset(x: 2 * scale)
            }
            .font(.system(size: 10 * scale, weight: .semibold))
            .foregroundStyle(Color.accentColor)
            .accessibilityLabel(Text("Read"))
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(MessagesInbox.mockConversation.messages) { message in
                MessageBubbleView(message: message)
            }
        }
        .padding()
    }
    .screenStyle(bgColor: .BG_2)
}
