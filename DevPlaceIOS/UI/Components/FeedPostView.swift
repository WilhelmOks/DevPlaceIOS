import SwiftUI
import DevPlaceSwiftSDK

struct FeedPostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hLine()
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                topArea()
                
                if let title = post.data.title {
                    Text(title).font(.title)
                }
                
                Text(post.data.content)
            }
            .padding(.horizontal)
            
            hLine()
                .padding(.top, 8)
        }
        .foregroundStyle(Color.FG_1)
        .background {
            Color.BG_2
        }
    }
    
    @ViewBuilder private func hLine() -> some View {
        Color.FG_2.frame(height: 1).opacity(0.3)
    }
    
    @ViewBuilder private func topArea() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                UserAvatarView(user: post.author)
                
                if let topic = post.data.topic {
                    CapsuleLabel(text: topic)
                }
            }
            
            Spacer()
            
            RelativeTimeLabel(date: post.data.createdAt)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 16) {
            let posts = [Post].mock
            ForEach(posts, id: \.id) { post in
                FeedPostView(post: post)
            }
        }
        .frame(maxWidth: .infinity)
    }
    .background {
        Color.BG_1.ignoresSafeArea()
    }
}
