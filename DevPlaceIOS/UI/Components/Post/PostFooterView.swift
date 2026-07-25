import SwiftUI
import DevPlaceSwiftSDK

struct PostFooterView: View {
    let targetId: String
    let starCount: Int
    let currentVote: Vote
    let reactions: Reactions
    let onReact: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack(spacing: 12) {
                VoteView(targetType: .post, targetId: targetId, count: starCount, currentVote: currentVote)
                
                ReactionsBar(reactions: reactions, onReact: onReact)
                
                Spacer(minLength: 0)
            }
        }
    }
}
