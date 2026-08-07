import SwiftUI
import MarkdownUI
import DevPlaceSwiftSDK

struct MessageBubbleView: View {
    let message: Message
    let maxBubbleWidth: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private let cornerRadius: CGFloat = 16
    private let tailCornerRadius: CGFloat = 4

    var body: some View {
        bubble()
            .frame(maxWidth: .infinity, alignment: message.isMine ? .trailing : .leading)
    }

    @ViewBuilder private func bubble() -> some View {
        HuggingWidthLayout(maxWidth: maxBubbleWidth) {
            VStack(alignment: bubbleAlignment, spacing: 8) {
                if !message.data.content.isEmpty {
                    Markdown(message.data.content)
                        .markdownTheme(.devPlace)
                        .markdownSoftBreakMode(.lineBreak)
                        .selectableTextPopover(message.data.content)
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
        .background(bubbleGradient)
        .clipShape(bubbleShape)
        .overlay {
            bubbleShape.strokeBorder(Color.FG_2.opacity(0.12), lineWidth: 1)
        }
    }

    @ViewBuilder private func footer() -> some View {
        HStack(spacing: 6) {
            RelativeTimeLabel(date: message.data.createdAt)

            if message.isMine {
                DoubleCheckmark(read: message.data.read)
            }
        }
    }

    private var bubbleShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: message.isMine ? cornerRadius : tailCornerRadius,
            bottomTrailingRadius: message.isMine ? tailCornerRadius : cornerRadius,
            topTrailingRadius: cornerRadius,
        )
    }

    private var bubbleAlignment: HorizontalAlignment {
        message.isMine ? .trailing : .leading
    }

    private var bubbleGradient: LinearGradient {
        LinearGradient(
            colors: [
                bubbleColor.mix(with: .white, by: topBrighten),
                bubbleColor.mix(with: .black, by: bottomDarken),
            ],
            startPoint: .top,
            endPoint: .bottom,
        )
    }

    private var topBrighten: Double {
        let isDark = colorScheme == .dark
        if message.isMine {
            return isDark ? 0.10 : 0.36
        } else {
            return isDark ? 0.12 : 0
        }
    }

    private var bottomDarken: Double {
        let isDark = colorScheme == .dark
        if message.isMine {
            return isDark ? 0.10 : 0.08
        } else {
            return isDark ? 0 : 0.12
        }
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
        subviews[0].sizeThatFits(ProposedViewSize(width: maxWidth, height: proposal.height))
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
                MessageBubbleView(message: message, maxBubbleWidth: 300)
            }
        }
        .padding()
    }
    .screenStyle(bgColor: .BG_2)
}
