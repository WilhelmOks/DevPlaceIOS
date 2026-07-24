import SwiftUI
import DevPlaceSwiftSDK

struct PostHeaderView: View {
    let author: User
    let topic: String?
    let date: Date
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                NavigationLink {
                    ProfileView(username: author.username)
                } label: {
                    UserAvatarView(user: author)
                }
                
                if let topic {
                    CapsuleLabel(text: topic)
                }
            }
            
            Spacer()
            
            RelativeTimeLabel(date: date)
        }
    }
}
