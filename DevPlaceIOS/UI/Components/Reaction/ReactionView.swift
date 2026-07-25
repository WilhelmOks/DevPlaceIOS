import SwiftUI

struct ReactionView: View {
    let emoji: String
    let count: Int
    let isMine: Bool
    
    @ScaledMetric private var scale = 1.0
    
    var body: some View {
        HStack(spacing: 4 * scale) {
            Text(emoji)
                .font(.system(size: 14 * scale))
            
            Text("\(count)")
                .font(.system(size: 14 * scale, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(Color.FG_1)
        }
        .reactionChip(isMine: isMine)
    }
}

#Preview {
    HStack(spacing: 8) {
        ReactionView(emoji: "🚀", count: 1, isMine: false)
        ReactionView(emoji: "🔥", count: 2, isMine: true)
        ReactionView(emoji: "🤯", count: 1, isMine: false)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
        Color.BG_1.ignoresSafeArea()
    }
}
