import SwiftUI
import DevPlaceSwiftSDK

struct ReactionsStack: View {
    let reactions: Reactions
    let onSelect: (String) -> Void
    
    @State private var isShowingAll = false
    @State private var visibleChipCount = Int.max
    
    @ScaledMetric private var scale = 1.0
    
    private let spacing: CGFloat = 6
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
            ReactionRowLayout(spacing: spacing, visibleChipCount: $visibleChipCount) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    reactionButton(item)
                        .accessibilityHidden(index >= visibleChipCount)
                }

                moreButton()
                    .accessibilityHidden(visibleChipCount >= items.count)
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
    
    @ViewBuilder private func moreButton() -> some View {
        Button {
            isShowingAll = true
        } label: {
            moreIndicator()
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
    
    @ViewBuilder private func moreIndicator() -> some View {
        Text("…")
            .font(.system(size: 14 * scale))
            .foregroundStyle(Color.FG_1)
            .reactionChip()
            .accessibilityLabel(Text("Show all reactions"))
    }
}

private struct ReactionRowLayout: Layout {
    let spacing: CGFloat
    @Binding var visibleChipCount: Int

    private let hiddenOffset: CGFloat = -100_000

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        plan(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = plan(proposal: proposal, subviews: subviews)
        publishVisibleChipCount(plan: plan, subviews: subviews)
        var x = bounds.minX
        for index in subviews.indices {
            if plan.visibleIndices.contains(index) {
                let size = plan.sizes[index]
                let y = bounds.minY + (plan.size.height - size.height) / 2
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(size),
                )
                x += size.width + spacing
            } else {
                subviews[index].place(
                    at: CGPoint(x: hiddenOffset, y: bounds.minY),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(plan.sizes[index]),
                )
            }
        }
    }

    private func publishVisibleChipCount(plan: Plan, subviews: Subviews) {
        let chipCount = subviews.count - 1
        let visible = plan.visibleIndices.filter { $0 < chipCount }.count
        guard visible != visibleChipCount else { return }
        DispatchQueue.main.async {
            visibleChipCount = visible
        }
    }

    private func plan(proposal: ProposedViewSize, subviews: Subviews) -> Plan {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let height = sizes.map(\.height).max() ?? 0

        guard subviews.count > 1 else {
            let indices = Array(subviews.indices)
            let width = sizes.map(\.width).reduce(0, +)
            return Plan(sizes: sizes, visibleIndices: indices, size: CGSize(width: width, height: height))
        }

        let moreIndex = subviews.count - 1
        let chipCount = moreIndex
        let available = proposal.width ?? .infinity

        let allChipsWidth = sizes[0..<chipCount].map(\.width).reduce(0, +) + spacing * CGFloat(chipCount - 1)
        if allChipsWidth <= available {
            return Plan(
                sizes: sizes,
                visibleIndices: Array(0..<chipCount),
                size: CGSize(width: allChipsWidth, height: height),
            )
        }

        let moreWidth = sizes[moreIndex].width
        var fittingCount = 0
        var usedWidth: CGFloat = 0
        for index in 0..<chipCount {
            let candidate = usedWidth + (index > 0 ? spacing : 0) + sizes[index].width
            if candidate + spacing + moreWidth <= available {
                usedWidth = candidate
                fittingCount = index + 1
            } else {
                break
            }
        }

        var visibleIndices = Array(0..<fittingCount)
        visibleIndices.append(moreIndex)
        let width = usedWidth + (fittingCount > 0 ? spacing : 0) + moreWidth
        return Plan(sizes: sizes, visibleIndices: visibleIndices, size: CGSize(width: width, height: height))
    }

    private struct Plan {
        let sizes: [CGSize]
        let visibleIndices: [Int]
        let size: CGSize
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
