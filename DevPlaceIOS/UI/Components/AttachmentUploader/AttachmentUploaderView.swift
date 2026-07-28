import SwiftUI
import UniformTypeIdentifiers
import DevPlaceSwiftSDK

struct AttachmentUploaderView: View {
    @Binding var attachments: [UploadResponse]
    
    @Environment(\.api) var api
    
    var body: some View {
        AttachmentUploaderViewContent(
            viewModel: .init(
                attachments: $attachments,
                api: api,
            )
        )
    }
}

private struct AttachmentUploaderViewContent: View {
    @State var viewModel: AttachmentUploaderView.ViewModel
    
    @State private var isShowingAddChoice = false
    @State private var isShowingUrlPrompt = false
    @State private var urlText = ""
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
            .fileImporter(
                isPresented: $viewModel.isShowingFileImporter,
                allowedContentTypes: [.item],
            ) { result in
                Task {
                    await viewModel.uploadPickedFile(result: result)
                }
            }
            .alert("Add from URL", isPresented: $isShowingUrlPrompt) {
                TextField("https://…", text: $urlText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.URL)
                Button("Cancel", role: .cancel) {
                    urlText = ""
                }
                Button("Add") {
                    let url = urlText
                    urlText = ""
                    Task {
                        await viewModel.uploadFromUrl(url: url)
                    }
                }
            } message: {
                Text("Enter the URL of the file to attach.")
            }
    }
    
    @ViewBuilder private func content() -> some View {
        BoxView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.attachments) { attachment in
                    attachmentRow(attachment: attachment)
                }
                
                if viewModel.isBusy {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
                
                if viewModel.canAddMore {
                    addButton()
                }
            }
        }
    }
    
    @ViewBuilder private func attachmentRow(attachment: UploadResponse) -> some View {
        HStack(spacing: 10) {
            Image(systemName: iconName(for: attachment))
                .foregroundStyle(Color.FG_2)
            
            Text(attachment.filename)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                Task {
                    await viewModel.delete(attachment: attachment)
                }
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .disabled(viewModel.isBusy)
        }
    }
    
    @ViewBuilder private func addButton() -> some View {
        Button {
            isShowingAddChoice = true
        } label: {
            Label("Add Attachment", systemImage: "paperclip")
        }
        .disabled(viewModel.isBusy)
        .confirmationDialog("Add Attachment", isPresented: $isShowingAddChoice, titleVisibility: .visible) {
            Button("Upload from Device") {
                viewModel.isShowingFileImporter = true
            }
            Button("Add from URL") {
                isShowingUrlPrompt = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func iconName(for attachment: UploadResponse) -> String {
        if attachment.isImage {
            return "photo"
        } else if attachment.isVideo {
            return "film"
        } else {
            return "doc"
        }
    }
}

#Preview("Empty") {
    StatefulPreviewWrapper([UploadResponse]()) { attachments in
        AttachmentUploaderView(attachments: attachments)
            .padding()
            .background(Color.BG_1)
    }
    .environment(\.api, .mock)
}

#Preview("With attachments") {
    StatefulPreviewWrapper(
        [
            UploadResponse(
                id: "1",
                filename: "screenshot.png",
                url: "https://example.com/screenshot.png",
                size: 1024,
                isImage: true,
                isVideo: false,
                mimeType: "image/png",
            ),
            UploadResponse(
                id: "2",
                filename: "demo.mp4",
                url: "https://example.com/demo.mp4",
                size: 2048,
                isImage: false,
                isVideo: true,
                mimeType: "video/mp4",
            ),
        ]
    ) { attachments in
        AttachmentUploaderView(attachments: attachments)
            .padding()
            .background(Color.BG_1)
    }
    .environment(\.api, .mock)
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content
    
    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}
