import SwiftUI
import DevPlaceSwiftSDK

struct ContentView: View {
    var api: DevPlaceApi = .prod
    @State var feed: Feed?
    @State var appState = AppState.shared
    
    var posts: [Post] {
        feed?.posts ?? []
    }
    
    @State private var logInPresented = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button("go to log in") {
                    logInPresented = true
                }
                .buttonStyle(.bordered)
                
                Button("create a test post") {
                    Task {
                        try await api.post(title: "test", topic: "test topic", content: "test post from ios")
                    }
                }
                .buttonStyle(.bordered)
                
                Button("reload feed") {
                    Task {
                        do {
                            feed = try await api.feed()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
                .buttonStyle(.bordered)
                
                ForEach(posts) { post in
                    Text(post.data.content)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $logInPresented) {
            LogInView(api: api)
        }
        .onChange(of: appState.token) { _, _ in
            Task {
                feed = try await api.feed()
            }
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
