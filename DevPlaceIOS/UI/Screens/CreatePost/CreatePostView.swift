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
                    .disabled(!viewModel.canSubmit)
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack {
                topicArea()
                titleArea()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
    
    @ViewBuilder private func topicArea() -> some View {
        HStack {
            Text("Topic")
            
            Picker(selection: $viewModel.postTopic, label: Text("Topic")) {
                ForEach(PostTopic.allCases, id: \.self) { topic in
                    Text(topic.name).tag(topic)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder private func titleArea() -> some View {
        VStack(alignment: .leading) {
            TextField("Title (optional)", text: $viewModel.title)
                .textFieldStyle(.devPlace)
            
            CharacterCounterView(text: viewModel.title, maxCount: viewModel.titleLimit)
                .padding(.horizontal, 11)
        }
    }
    
    @ViewBuilder private func messageArea() -> some View {
        
    }
}

#Preview {
    NavigationStack {
        CreatePostView()
    }
}
