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
    
    enum FocusableItem: Identifiable {
        case title
        case message
        
        var id: Self { self }
    }
    
    @FocusState private var focusedField: FocusableItem?
    
    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .onTapGesture {
                focusedField = nil
            }
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
            VStack(spacing: 14) {
                topicArea()
                titleArea()
                messageArea()
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
            TextField(
                text: $viewModel.title,
                label: {
                    Text("Title (optional)")
                        .foregroundStyle(.FG_2.opacity(0.5))
                }
            )
            .textFieldStyle(.devPlace)
            .focused($focusedField, equals: .title)
            .onSubmit {
                focusedField = .message
            }
            
            CharacterCounterView(text: viewModel.title, maxCount: viewModel.titleLimit)
                .padding(.horizontal, 11)
        }
    }
    
    @ViewBuilder private func messageArea() -> some View {
        VStack(alignment: .leading) {
            DevPlaceTextEditor(
                text: $viewModel.message,
                placeholder: "What's on your mind?",
                initialLineCount: 7
            )
            .focused($focusedField, equals: .message)
            
            CharacterCounterView(text: viewModel.message, maxCount: viewModel.messageLimit)
                .padding(.horizontal, 11)
        }
    }
}

#Preview {
    NavigationStack {
        CreatePostView()
    }
}
