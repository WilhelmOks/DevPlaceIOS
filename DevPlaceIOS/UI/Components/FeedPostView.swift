import SwiftUI
import DevPlaceSwiftSDK

struct FeedPostView: View {
    let post: Post
    let appSettings = AppSettingsStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hLine()
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                PostHeaderView(author: post.author, date: post.data.createdAt)
                
                postContentLink()
                
                if let poll = post.poll {
                    PollView(poll: poll)
                }
                
                if appSettings.showFeedAttachments, let attachment = post.attachments.first {
                    AttachmentViewer(attachment: attachment)
                }
                
                Divider()
                
                VoteView(targetType: .post, targetId: post.data.id, count: post.data.stars, currentVote: post.myVote)
            }
            .padding(.horizontal)
            
            hLine()
                .padding(.top, 8)
        }
        .foregroundStyle(Color.FG_1)
        .background {
            Color.BG_1
        }
    }
    
    @ViewBuilder private func hLine() -> some View {
        Color.FG_2.frame(height: 1).opacity(0.3)
    }
    
    @ViewBuilder private func postContentLink() -> some View {
        if let slug = post.data.slug {
            NavigationLink {
                PostView(slug: slug)
            } label: {
                PostContentView(topic: post.data.topic, title: post.data.title, content: post.data.content)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            PostContentView(topic: post.data.topic, title: post.data.title, content: post.data.content)
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
        Color.BG_2.ignoresSafeArea()
    }
    .environment(\.api, .mock)
}
