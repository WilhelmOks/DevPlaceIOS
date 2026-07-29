import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import DevPlaceSwiftSDK

struct AttachmentUploaderView: View {
    var attachments: [UploadResponse] = []
    var onAttachmentsChange: ([UploadResponse]) -> Void = { _ in }
    
    @Environment(\.api) var api
    
    var body: some View {
        AttachmentUploaderViewContent(
            viewModel: .init(
                attachments: attachments,
                api: api,
                onAttachmentsChange: onAttachmentsChange,
            )
        )
    }
}

private struct AttachmentUploaderViewContent: View {
    @State var viewModel: AttachmentUploaderView.ViewModel
    
    @State private var isShowingAddChoice = false
    @State private var isShowingUrlPrompt = false
    @State private var isShowingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
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
            .photosPicker(
                isPresented: $isShowingPhotoPicker,
                selection: $selectedPhoto,
                matching: .any(of: [.images, .videos]),
            )
            .onChange(of: selectedPhoto) { _, newItem in
                guard let newItem else { return }
                Task {
                    await uploadPhoto(newItem)
                    selectedPhoto = nil
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
            
            Text(attachment.filename ?? "file")
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
            Button("Photo Library") {
                isShowingPhotoPicker = true
            }
            Button("Files") {
                viewModel.isShowingFileImporter = true
            }
            Button("From URL") {
                isShowingUrlPrompt = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func uploadPhoto(_ item: PhotosPickerItem) async {
        await viewModel.uploadFile {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                return nil
            }
            let contentType = item.supportedContentTypes.first
            let mimeType = contentType?.preferredMIMEType ?? "application/octet-stream"
            let fileExtension = contentType?.preferredFilenameExtension
            let filename = fileExtension.map { "attachment.\($0)" } ?? "attachment"
            return (data, filename, mimeType)
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
    AttachmentUploaderView()
        .padding()
        .background(Color.BG_1)
        .environment(\.api, .mock)
}

#Preview("With attachments") {
    AttachmentUploaderViewContent(
        viewModel: .init(
            attachments: [
                UploadResponse(
                    id: "1",
                    filename: "screenshot.png",
                    url: "https://example.com/screenshot.png",
                    size: 1024,
                    isImage: true,
                    isVideo: false,
                    isAudio: false,
                    mimeType: "image/png",
                ),
                UploadResponse(
                    id: "2",
                    filename: "demo.mp4",
                    url: "https://example.com/demo.mp4",
                    size: 2048,
                    isImage: false,
                    isVideo: true,
                    isAudio: false,
                    mimeType: "video/mp4",
                ),
            ],
            api: .mock,
        )
    )
    .padding()
    .background(Color.BG_1)
}
