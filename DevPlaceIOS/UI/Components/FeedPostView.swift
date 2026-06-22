import SwiftUI
import DevPlaceSwiftSDK

struct FeedPostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hLine()
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                if let title = post.data.title {
                    Text(title).font(.largeTitle)
                }
                
                if let topic = post.data.topic {
                    Text(topic).font(.title)
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
