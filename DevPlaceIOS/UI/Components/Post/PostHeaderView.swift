import SwiftUI
import DevPlaceSwiftSDK

struct PostHeaderView: View {
    let author: User
    let date: Date
    var linksToProfile: Bool = true
    
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
            
            RelativeTimeLabel(date: date)
        }
    }
}
