import SwiftUI
import DevPlaceSwiftSDK

struct CreatePostView: View {
    @Environment(\.api) var api
    
    var body: some View {
        CreatePostViewContent(viewModel: .init(api: api))
    }
}

private struct CreatePostViewContent: View {
    @State var viewModel: CreatePostView.ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Create New Post"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //dismiss()
                    } label: {
                        Label("Create", systemImage: "paperplane.fill")
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Topic")
                    
                    Picker(selection: $viewModel.postTopic, label: Text("Topic")) {
                        ForEach(PostTopic.allCases, id: \.self) { topic in
                            Text(topic.name).tag(topic)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        CreatePostView()
    }
}
