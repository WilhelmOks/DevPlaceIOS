import SwiftUI

struct ReactionChipStyle: ViewModifier {
    var isMine: Bool
    
    @ScaledMetric private var scale = 1.0
    
    private let mineFillOpacity: Double = 0.15
    private let normalBorderOpacity: Double = 0.25
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10 * scale)
            .padding(.vertical, 5 * scale)
            .background {
                Capsule()
                    .fill(isMine ? Color.accentColor.opacity(mineFillOpacity) : Color.BG_2)
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        isMine ? Color.accentColor : Color.FG_2.opacity(normalBorderOpacity),
                        lineWidth: isMine ? 1.5 : 1,
                    )
            }
    }
}

extension View {
    func reactionChip(isMine: Bool = false) -> some View {
        modifier(ReactionChipStyle(isMine: isMine))
    }
}
