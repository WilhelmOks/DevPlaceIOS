import SwiftUI
import DevPlaceSwiftSDK

struct PostHeaderView: View {
    let author: User
    let date: Date
    
    var body: some View {
        HStack(alignment: .top) {
            NavigationLink {
                ProfileView(username: author.username)
            } label: {
                UserAvatarView(user: author)
            }
            
            Spacer()
            
            RelativeTimeLabel(date: date)
        }
    }
}
