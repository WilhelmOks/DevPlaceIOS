import SwiftUI
import DevPlaceSwiftSDK

struct ContentView: View {
    var api: DevPlaceApi = .prod
    @State var feed: Feed?
    
    var posts: [Post] {
        feed?.posts ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(posts) { post in
                    Text(post.data.content)
                }
            }
            .padding()
        }
        .task {
            do {
                feed = try await api.feed()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview("mock") {
    ContentView(api: .mock)
}

#Preview("prod") {
    ContentView()
}
