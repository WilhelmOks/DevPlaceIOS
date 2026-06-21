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
                Button("create a test post") {
                    Task {
                        try await api.post(title: "test", topic: "test topic", content: "test post from ios")
                    }
                }
                .buttonStyle(.bordered)
                
                ForEach(posts) { post in
                    Text(post.data.content)
                }
            }
            .padding()
        }
        .task {
            do {
                try await api.logIn(email: "(my email)", password: "(my password)")
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
