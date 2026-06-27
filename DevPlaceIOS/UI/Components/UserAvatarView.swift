import SwiftUI
import DevPlaceSwiftSDK

struct UserAvatarView: View {
    let user: User
    
    var body: some View {
        HStack {
            UserImage(user: user)
            
            VStack(alignment: .leading) {
                Group {
                    Text(user.username)
                        .fontWeight(.semibold)
                    
                    Text("Level \(user.level)")
                        .font(.caption)
                        .foregroundStyle(Color.FG_2)
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 10) {
            UserAvatarView(user: .mock)
            UserAvatarView(user: .mock2)
        }
        .padding()
    }
    .screenStyle()
}
