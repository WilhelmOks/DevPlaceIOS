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
    
    @State private var selectedPostSlug: String?
    
    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Feed"))
            .alert($viewModel.alertMessage)
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(item: $selectedPostSlug) { slug in
                PostView(slug: slug)
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            LazyVStack {
                let posts = appState.feed?.posts ?? []
                ForEach(posts, id: \.id) { post in
                    FeedPostView(post: post) { slug in
                        selectedPostSlug = slug
                    }
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
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
}
