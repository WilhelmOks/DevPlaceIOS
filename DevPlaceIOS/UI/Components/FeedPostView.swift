import SwiftUI
import MarkdownUI
import DevPlaceSwiftSDK

struct FeedPostView: View {
    let post: Post
    let appSettings = AppSettingsStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hLine()
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                topArea()
                
                if let title = post.data.title {
                    let markdownTitle = LocalizedStringKey(title)
                    Text(markdownTitle)
                        .lineSpacing(0)
                        .font(.title)
                }
                
                Markdown(post.data.content)
                    .markdownTheme(.devPlace)
                    .markdownSoftBreakMode(.lineBreak)
                
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
    
    @ViewBuilder private func topArea() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                NavigationLink {
                    ProfileView(username: post.author.username)
                } label: {
                    UserAvatarView(user: post.author)
                }
                
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
        Color.BG_2.ignoresSafeArea()
    }
    .environment(\.api, .mock)
}
