import SwiftUI
import DevPlaceSwiftSDK

struct PostFooterView: View {
    let targetId: String
    let starCount: Int
    let currentVote: Vote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            VoteView(targetType: .post, targetId: targetId, count: starCount, currentVote: currentVote)
        }
    }
}
