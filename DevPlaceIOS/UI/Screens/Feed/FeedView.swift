import SwiftUI
import DevPlaceSwiftSDK

struct FeedView: View {
    @Environment(\.api) var api
    
    var body: some View {
        FeedViewContent(viewModel: .init(api: api))
    }
}

private struct FeedViewContent: View {
    @State var viewModel: FeedView.ViewModel
    let appState = AppState.shared
    
    @State private var selectedPost: PostDestination?
    
    struct PostDestination: Hashable, Identifiable {
        let slug: String
        let scrollToCommentId: String?
        
        var id: Self { self }
    }
    
    enum SheetItem: Identifiable {
        case createPost
        
        var id: Self { self }
    }
    
    @State private var sheetItem: SheetItem?
    @State private var activeReplyTargetId: String?
    @State private var editingCommentId: String?
    
    private var isComposing: Bool {
        activeReplyTargetId != nil || editingCommentId != nil
    }
    
    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Posts"))
            .alert($viewModel.alertMessage)
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(item: $selectedPost) { destination in
                PostView(slug: destination.slug, scrollToCommentId: destination.scrollToCommentId)
            }
            .fullScreenCover(item: $sheetItem) { item in
                switch item {
                case .createPost:
                    NavigationStack {
                        CreatePostView(mode: .create)
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            LazyVStack {
                let posts = appState.feed?.posts ?? []
                ForEach(posts, id: \.id) { post in
                    FeedPostView(
                        post: post,
                        onSelect: { slug, scrollToCommentId in
                            selectedPost = PostDestination(slug: slug, scrollToCommentId: scrollToCommentId)
                        },
                        activeReplyTargetId: $activeReplyTargetId,
                        editingCommentId: $editingCommentId,
                    )
                }
                if appState.feed?.nextCursor != nil {
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .overlay(alignment: .bottomTrailing) {
            if !isComposing {
                Button {
                    sheetItem = .createPost
                } label: {
                    Label("New post", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.accentGradient(shape: .circle))
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
}
