import SwiftUI
import DevPlaceSwiftSDK

struct ReactionsStack: View {
    let reactions: Reactions
    let onSelect: (String) -> Void
    
    @State private var isShowingAll = false
    
    @ScaledMetric private var scale = 1.0
    
    private let spacing: CGFloat = 6
    private let fillOpacity: Double = 0.12
    private let borderOpacity: Double = 0.25
    private let popoverWidth: CGFloat = 300
    
    private var items: [ReactionItem] {
        reactions.counts
            .map { emoji, count in
                ReactionItem(emoji: emoji, count: count, isMine: reactions.mine.contains(emoji))
            }
            .sorted { lhs, rhs in
                lhs.count != rhs.count ? lhs.count > rhs.count : lhs.emoji < rhs.emoji
            }
    }
    
    var body: some View {
        if !items.isEmpty {
            ViewThatFits(in: .horizontal) {
                ForEach(Array((0...items.count).reversed()), id: \.self) { visibleCount in
                    row(visibleCount: visibleCount)
                }
            }
        }
    }
    
    @ViewBuilder private func row(visibleCount: Int) -> some View {
        let hiddenCount = items.count - visibleCount
        HStack(spacing: spacing) {
            ForEach(Array(items.prefix(visibleCount))) { item in
                reactionButton(item)
            }
            
            if hiddenCount > 0 {
                moreButton(hiddenCount: hiddenCount)
            }
        }
    }
    
    @ViewBuilder private func reactionButton(_ item: ReactionItem) -> some View {
        Button {
            onSelect(item.emoji)
        } label: {
            ReactionView(emoji: item.emoji, count: item.count, isMine: item.isMine)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func moreButton(hiddenCount: Int) -> some View {
        Button {
            isShowingAll = true
        } label: {
            moreIndicator(count: hiddenCount)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingAll) {
            allReactionsPopover()
        }
    }
    
    @ViewBuilder private func allReactionsPopover() -> some View {
        VFlowStack(alignment: .leading, spacing: spacing) {
            ForEach(items) { item in
                Button {
                    onSelect(item.emoji)
                    isShowingAll = false
                } label: {
                    ReactionView(emoji: item.emoji, count: item.count, isMine: item.isMine)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: popoverWidth)
        .presentationCompactAdaptation(.popover)
    }
    
    @ViewBuilder private func moreIndicator(count: Int) -> some View {
        Text("+\(count)")
            .font(.system(size: 14 * scale, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(Color.FG_1)
            .padding(.horizontal, 10 * scale)
            .padding(.vertical, 5 * scale)
            .background {
                Capsule().fill(Color.FG_2.opacity(fillOpacity))
            }
            .overlay {
                Capsule().strokeBorder(Color.FG_2.opacity(borderOpacity), lineWidth: 1)
            }
    }
}

private struct ReactionItem: Identifiable {
    let emoji: String
    let count: Int
    let isMine: Bool
    
    var id: String { emoji }
}

#Preview {
    let reactions = Reactions(
        mine: ["🔥"],
        counts: ["🚀": 2, "🔥": 2, "👍": 5, "🎉": 1, "😂": 3],
    )
    
    return VStack(alignment: .leading, spacing: 20) {
        ReactionsStack(reactions: reactions) { emoji in
            dlog("Selected \(emoji)")
        }
        .frame(width: 210, alignment: .leading)
        
        ReactionsStack(reactions: reactions) { emoji in
            dlog("Selected \(emoji)")
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
        Color.BG_1.ignoresSafeArea()
    }
}
