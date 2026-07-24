import SwiftUI
import DevPlaceSwiftSDK

struct PostView: View {
    let slug: String
    
    @Environment(\.api) var api
    
    var body: some View {
        PostViewContent(viewModel: .init(slug: slug, api: api))
    }
}

private struct PostViewContent: View {
    @State var viewModel: PostView.ViewModel
    
    var body: some View {
        content()
            .screenStyle(bgColor: .BG_1)
            .navigationTitle(Text(viewModel.navigationTitle))
            .navigationBarTitleDisplayMode(.inline)
            .alert($viewModel.alertMessage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    reloadToolbarItem()
                }
            }
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder private func content() -> some View {
        if let postDetail = viewModel.postDetail {
            ScrollView {
                postBody(postDetail)
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder private func postBody(_ detail: PostDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PostHeaderView(
                author: detail.author,
                date: detail.post.createdAt,
            )
            
            PostContentView(topic: detail.post.topic, title: detail.post.title, content: detail.post.content)
            
            if let poll = detail.poll {
                PollView(poll: poll)
            }
            
            ForEach(detail.attachments, id: \.id) { attachment in
                AttachmentViewer(attachment: attachment)
            }
            
            PostFooterView(targetId: detail.post.id, starCount: detail.starCount, currentVote: detail.currentVote)
            
            // TODO: show the post's comments below the content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .foregroundStyle(Color.FG_1)
        .background {
            Color.BG_1
        }
    }
    
    @ViewBuilder private func reloadToolbarItem() -> some View {
        if viewModel.isReloading {
            ProgressView()
        } else {
            Button {
                Task { await viewModel.reload() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostView(slug: "mock-slug")
    }
    .environment(\.api, .mock)
}
