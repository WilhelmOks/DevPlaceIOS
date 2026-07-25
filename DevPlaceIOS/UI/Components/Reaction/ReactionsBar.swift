import SwiftUI
import DevPlaceSwiftSDK

struct ReactionsBar: View {
    let reactions: Reactions
    let onReact: (String) -> Void
    
    @State private var isPickingEmoji = false
    
    @ScaledMetric private var scale = 1.0
    
    private let spacing: CGFloat = 6
    
    var body: some View {
        HStack(spacing: spacing) {
            ReactionsStack(reactions: reactions, onSelect: onReact)
            
            addReactionButton()
        }
    }
    
    @ViewBuilder private func addReactionButton() -> some View {
        Button {
            isPickingEmoji = true
        } label: {
            Image(systemName: "face.smiling")
                .font(.system(size: 15 * scale))
                .foregroundStyle(Color.FG_2)
                .reactionChip()
        }
        .accessibilityLabel(Text("Add reaction"))
        .buttonStyle(.plain)
        .sheet(isPresented: $isPickingEmoji) {
            NavigationStack {
                EmojiPicker { emoji in
                    onReact(emoji)
                }
            }
        }
    }
}

#Preview {
    let reactions = Reactions(
        mine: ["🔥"],
        counts: ["🚀": 2, "🔥": 2, "👍": 5],
    )
    
    return ReactionsBar(reactions: reactions) { emoji in
        dlog("React \(emoji)")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
        Color.BG_1.ignoresSafeArea()
    }
}
