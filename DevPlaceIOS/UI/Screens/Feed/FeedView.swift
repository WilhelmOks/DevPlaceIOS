import SwiftUI
import DevPlaceSwiftSDK

struct FeedView: View {
    @Environment(\.api) var api
    
    @Binding var selectedPost: PostDestination?
    let reselectSignal: Bool
    
    var body: some View {
        FeedViewContent(viewModel: .init(api: api), selectedPost: $selectedPost, reselectSignal: reselectSignal)
    }
}

private struct FeedViewContent: View {
    @State var viewModel: FeedView.ViewModel
    let appState = AppState.shared
    
    @Binding var selectedPost: PostDestination?
    let reselectSignal: Bool
    
    @State private var isAtTop = true
    
    enum SheetItem: Identifiable {
        case createPost
        
        var id: Self { self }
    }
    
    @State private var sheetItem: SheetItem?
    @State private var activeReplyTargetId: String?
    @State private var editingCommentId: String?
    @State private var pendingEditQuote: String?
    @State private var mentionListHeight: CGFloat = 0
    
    private var isComposing: Bool {
        activeReplyTargetId != nil || editingCommentId != nil
    }
    
    private func insertQuote(_ quote: String) {
        if editingCommentId != nil {
            pendingEditQuote = quote
        } else if activeReplyTargetId != nil {
            AppSettingsStore.shared.draftReplyMessage += quote
        }
    }
    
    var body: some View {
        content()
            .environment(
                \.quoteComposer,
                QuoteComposer(isActive: isComposing, insert: insertQuote),
            )
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Posts"))
            .navigationBarTitleDisplayMode(.inline)
            .alert($viewModel.alertMessage)
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: reselectSignal) {
                if isAtTop {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationDestination(item: $selectedPost) { destination in
                PostView(slug: destination.slug, scrollToCommentId: destination.scrollToCommentId)
                    .id(destination)
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
        ScrollViewReader { proxy in
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
                            pendingEditQuote: pendingEditQuote,
                            onConsumeEditQuote: { pendingEditQuote = nil },
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
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y <= geometry.contentInsets.top
            } action: { _, newValue in
                isAtTop = newValue
            }
            .onPreferenceChange(MentionListHeightKey.self) { newHeight in
                mentionListHeight = newHeight
            }
            .onChange(of: mentionListHeight) {
                proxy.scrollTo(CommentEditorView.scrollAnchorName, anchor: .bottom)
            }
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
    @Previewable @State var selectedPost: PostDestination?
    NavigationStack {
        FeedView(selectedPost: $selectedPost, reselectSignal: false)
    }
}
