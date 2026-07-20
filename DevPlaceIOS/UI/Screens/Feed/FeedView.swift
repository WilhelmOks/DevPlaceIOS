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
    @State var appState: AppState = .shared
    
    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Feed"))
            .alert($viewModel.alertMessage)
            .onAppear {
                if appState.feed == nil {
                    Task {
                        await viewModel.load()
                    }
                }
            }
            .refreshable {
                await viewModel.load()
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            LazyVStack {
                let posts = appState.feed?.posts ?? []
                ForEach(posts, id: \.id) { post in
                    FeedPostView(post: post)
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
