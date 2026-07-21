import SwiftUI

struct VFlowStack: Layout {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat? = nil
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void,
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = arrangeRows(subviews: subviews, maxWidth: maxWidth)
        let itemSpacing = spacing ?? 8
        
        let width = rows.map(\.width).max() ?? 0
        let totalHeight = rows.reduce(0) { $0 + $1.height }
        let spacingHeight = itemSpacing * CGFloat(max(0, rows.count - 1))
        
        return CGSize(width: width, height: totalHeight + spacingHeight)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void,
    ) {
        let rows = arrangeRows(subviews: subviews, maxWidth: bounds.width)
        let itemSpacing = spacing ?? 8
        var y = bounds.minY
        
        for row in rows {
            let rowOffset: CGFloat
            if alignment == .leading {
                rowOffset = 0
            } else if alignment == .trailing {
                rowOffset = bounds.width - row.width
            } else {
                rowOffset = (bounds.width - row.width) / 2
            }
            
            var x = bounds.minX + rowOffset
            
            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size),
                )
                x += item.size.width + itemSpacing
            }
            
            y += row.height + itemSpacing
        }
    }
    
    private func arrangeRows(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        let itemSpacing = spacing ?? 8
        var rows: [Row] = []
        var currentRow = Row()
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let projectedWidth = currentRow.items.isEmpty
                ? size.width
                : currentRow.width + itemSpacing + size.width
            
            if !currentRow.items.isEmpty && projectedWidth > maxWidth {
                rows.append(currentRow)
                currentRow = Row(
                    items: [Item(subview: subview, size: size)],
                    width: size.width,
                    height: size.height,
                )
            } else {
                currentRow.items.append(Item(subview: subview, size: size))
                currentRow.width = projectedWidth
                currentRow.height = max(currentRow.height, size.height)
            }
        }
        
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
    
    private struct Item {
        let subview: LayoutSubview
        let size: CGSize
    }
}

#Preview {
    VFlowStack(alignment: .leading, spacing: 8) {
        ForEach(0..<20, id: \.self) { i in
            Text("Item \(i)")
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.gray.opacity(0.2), in: Capsule())
        }
    }
    .padding()
}
