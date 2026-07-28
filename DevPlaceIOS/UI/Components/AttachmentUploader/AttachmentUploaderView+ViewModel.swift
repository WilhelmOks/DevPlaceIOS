import Foundation
import Observation
import UniformTypeIdentifiers
import DevPlaceSwiftSDK

extension AttachmentUploaderView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        @ObservationIgnored private let onAttachmentsChange: ([UploadResponse]) -> Void
        
        var attachments: [UploadResponse] {
            didSet {
                onAttachmentsChange(attachments)
            }
        }
        
        var isBusy = false
        var isShowingFileImporter = false
        var alertMessage: AlertMessage = .none()
        
        init(
            attachments: [UploadResponse] = [],
            api: DevPlaceApi,
            onAttachmentsChange: @escaping ([UploadResponse]) -> Void = { _ in },
        ) {
            self.attachments = attachments
            self.api = api
            self.onAttachmentsChange = onAttachmentsChange
        }
        
        var canAddMore: Bool {
            attachments.count < DevPlaceConstants.maxAttachmentsCount
        }
        
        func uploadPickedFile(result: Result<URL, Error>) async {
            guard canAddMore else { return }
            do {
                let url = try result.get()
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                let data = try Data(contentsOf: url)
                let filename = url.lastPathComponent
                let mimeType = (try? url.resourceValues(forKeys: [.contentTypeKey]))?
                    .contentType?
                    .preferredMIMEType ?? "application/octet-stream"
                
                await upload {
                    try await self.api.uploadFile(data: data, filename: filename, mimeType: mimeType)
                }
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        func uploadFromUrl(url: String) async {
            guard canAddMore else { return }
            let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            
            await upload {
                try await self.api.uploadFromUrl(url: trimmed, filename: nil)
            }
        }
        
        func delete(attachment: UploadResponse) async {
            guard !isBusy else { return }
            isBusy = true
            defer { isBusy = false }
            
            do {
                try await api.deleteAttachment(uid: attachment.id)
                attachments.removeAll { $0.id == attachment.id }
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        private func upload(_ operation: () async throws -> UploadResponse) async {
            guard !isBusy else { return }
            isBusy = true
            defer { isBusy = false }
            
            do {
                let uploaded = try await operation()
                attachments.append(uploaded)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
