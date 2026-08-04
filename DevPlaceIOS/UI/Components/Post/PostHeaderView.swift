import SwiftUI
import DevPlaceSwiftSDK

struct PostHeaderView: View {
    let author: User
    let date: Date
    var linksToProfile: Bool = true
    var commentCount: Int? = nil
    
    @ScaledMetric private var commentFontSize = 12.0
    
    var body: some View {
        HStack(alignment: .top) {
            if linksToProfile {
                NavigationLink {
                    ProfileView(username: author.username)
                } label: {
                    UserAvatarView(user: author)
                }
            } else {
                UserAvatarView(user: author)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                RelativeTimeLabel(date: date)
                
                if let commentCount, commentCount > 0 {
                    commentCountLabel(commentCount)
                }
            }
        }
    }
    
    @ViewBuilder private func commentCountLabel(_ count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "text.bubble")
            Text("\(count)")
        }
        .font(.system(size: commentFontSize))
        .foregroundStyle(Color.FG_2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(count) comments")
    }
}
