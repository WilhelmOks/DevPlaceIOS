import SwiftUI
import DevPlaceSwiftSDK

struct PostView: View {
    let slug: String
    var scrollToCommentId: String? = nil
    
    @Environment(\.api) var api
    
    var body: some View {
        PostViewContent(viewModel: .init(slug: slug, api: api), scrollToCommentId: scrollToCommentId)
    }
}

private struct PostViewContent: View {
    @State var viewModel: PostView.ViewModel
    var scrollToCommentId: String? = nil
    
    @State private var isEditingPost = false
    
    @Environment(\.dismiss) private var dismiss
    
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
            .fullScreenCover(isPresented: $isEditingPost) {
                if let post = viewModel.editablePost {
                    NavigationStack {
                        CreatePostView(mode: .edit(post)) {
                            Task { await viewModel.reload() }
                        }
                    }
                }
            }
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder private func content() -> some View {
        if let postDetail = viewModel.postDetail {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        postBody(postDetail)
                        
                        commentsSection(postDetail)
                    }
                }
                .onAppear {
                    scrollToTargetComment(using: proxy)
                }
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func scrollToTargetComment(using proxy: ScrollViewProxy) {
        guard let scrollToCommentId else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation {
                proxy.scrollTo(scrollToCommentId, anchor: .top)
            }
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
            
            PostFooterView(
                targetId: detail.post.id,
                starCount: detail.starCount,
                currentVote: detail.myVote,
                reactions: detail.reactions,
                onReact: { emoji in
                    Task { await viewModel.reactToPost(emoji: emoji) }
                },
                onEdit: AppState.shared.isCurrentUser(id: detail.post.userId)
                    ? { isEditingPost = true }
                    : nil,
                onDelete: AppState.shared.isCurrentUser(id: detail.post.userId)
                    ? {
                        Task {
                            if await viewModel.deletePost() {
                                dismiss()
                            }
                        }
                    }
                    : nil,
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .foregroundStyle(Color.FG_1)
        .background {
            Color.BG_1
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            if AppState.shared.isCurrentUser(id: detail.post.userId) {
                isEditingPost = true
            } else {
                Task { await viewModel.upvoteForeignPost() }
            }
        }
    }
    
    @ViewBuilder private func commentsSection(_ detail: PostDetail) -> some View {
        if !detail.comments.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Comments")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top)
                
                CommentsView(
                    comments: detail.comments,
                    onDoubleTapComment: { comment in
                        Task { await viewModel.doubleTapComment(comment) }
                    },
                    onReactComment: { comment, emoji in
                        Task { await viewModel.reactToComment(comment, emoji: emoji) }
                    },
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder private func reloadToolbarItem() -> some View {
        if viewModel.isReloading {
            ProgressView()
        } else {
            Button {
                Task { await viewModel.reload() }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
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
