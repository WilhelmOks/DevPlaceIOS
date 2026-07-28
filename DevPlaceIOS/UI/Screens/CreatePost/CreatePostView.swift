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
            .alert($viewModel.alertMessage)
            .disabled(viewModel.isLoading)
            .onTapGesture {
                focusedField = nil
            }
            .onReceive(viewModel.dismiss) {
                dismiss()
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
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await viewModel.submit()
                            }
                        } label: {
                            Label("Create", systemImage: "paperplane.fill")
                        }
                        .disabled(!viewModel.canSubmit)
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                topicArea()
                titleArea()
                messageArea()
                attachmentsArea()
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
            
            CharacterCounterView(
                text: viewModel.title,
                maxCount: DevPlaceConstants.maxPostTitleLength,
            )
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
            
            CharacterCounterView(
                text: viewModel.message,
                minCount: DevPlaceConstants.minPostContentLength,
                maxCount: DevPlaceConstants.maxPostContentLength,
            )
            .padding(.horizontal, 11)
        }
    }
    
    @ViewBuilder private func attachmentsArea() -> some View {
        AttachmentUploaderView { attachments in
            viewModel.attachments = attachments
        }
    }
}

#Preview {
    NavigationStack {
        CreatePostView()
    }
    .environment(\.api, .mock)
}
