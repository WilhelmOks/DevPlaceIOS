import Foundation
import Observation
import Combine
import DevPlaceSwiftSDK

extension CreatePostView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        private let settingsStore = AppSettingsStore.shared
        
        var postTopic: PostTopic = .random
        
        var title: String {
            didSet {
                settingsStore.draftPostTitle = title
            }
        }
        
        var message: String {
            didSet {
                settingsStore.draftPostMessage = message
            }
        }
        
        var attachments: [UploadResponse] = []
        
        var isPollAdded = false
        var pollQuestion = ""
        var pollOptions: [String] = []
        
        var alertMessage: AlertMessage = .none()
        var isLoading = false
        
        let dismiss = PassthroughSubject<Void, Never>()
        
        init(api: DevPlaceApi) {
            self.api = api
            self.title = settingsStore.draftPostTitle
            self.message = settingsStore.draftPostMessage
        }
        
        private let minPollOptionsCount = 2
        
        func addPoll() {
            while pollOptions.count < minPollOptionsCount {
                pollOptions.append("")
            }
            isPollAdded = true
        }
        
        func removePoll() {
            isPollAdded = false
        }
        
        var canSubmit: Bool {
            let titleLength = TextCharacterCounter.numberOfCharacters(title)
            let messageLength = TextCharacterCounter.numberOfCharacters(message)
            
            let titleOk = titleLength <= DevPlaceConstants.maxPostTitleLength
            let messageOk = messageLength <= DevPlaceConstants.maxPostContentLength && messageLength >= DevPlaceConstants.minPostContentLength
            return titleOk && messageOk
        }
        
        func submit() async {
            isLoading = true
            defer { isLoading = false }
            
            do {
                var cleanTitle: String? = self.title.trimmingCharacters(in: .whitespacesAndNewlines)
                if cleanTitle?.isEmpty == true {
                    cleanTitle = nil
                }
                
                try await api.createPost(
                    title: cleanTitle,
                    topic: postTopic,
                    content: message,
                    attachments: attachments,
                    pollQuestion: isPollAdded ? pollQuestion : nil,
                    pollOptions: isPollAdded ? pollOptions : [],
                )
                
                try? await AppState.shared.loadFeed(api: api)
                
                title = ""
                message = ""
                attachments = []
                isPollAdded = false
                pollQuestion = ""
                pollOptions = []
                
                dismiss.send()
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        func deleteUnsubmittedAttachments() async {
            let unsubmitted = attachments
            attachments = []
            
            for attachment in unsubmitted {
                do {
                    try await api.deleteAttachment(uid: attachment.id)
                } catch {
                    dlog("Failed to delete unsubmitted attachment \(attachment.id): \(error)")
                }
            }
        }
    }
}
