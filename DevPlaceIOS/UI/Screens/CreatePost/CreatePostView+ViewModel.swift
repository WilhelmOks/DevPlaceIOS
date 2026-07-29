import Foundation
import Observation
import Combine
import DevPlaceSwiftSDK

extension CreatePostView {
    enum Mode {
        case create
        case edit(Post)
    }
    
    @Observable final class ViewModel {
        let api: DevPlaceApi
        let mode: Mode
        private let settingsStore = AppSettingsStore.shared
        
        private let originalAttachmentIds: Set<String>
        
        var postTopic: PostTopic
        
        var title: String {
            didSet {
                if !isEditing {
                    settingsStore.draftPostTitle = title
                }
            }
        }
        
        var message: String {
            didSet {
                if !isEditing {
                    settingsStore.draftPostMessage = message
                }
            }
        }
        
        var attachments: [UploadResponse]
        
        var isPollAdded: Bool
        var pollQuestion: String
        var pollOptions: [String]
        
        var projects: [Project.Data] = []
        var selectedProjectId: String?
        
        var alertMessage: AlertMessage = .none()
        var isLoading = false
        
        let dismiss = PassthroughSubject<Void, Never>()
        
        var isEditing: Bool {
            if case .edit = mode {
                return true
            }
            return false
        }
        
        init(api: DevPlaceApi, mode: Mode) {
            self.api = api
            self.mode = mode
            
            switch mode {
            case .create:
                self.postTopic = .random
                self.title = settingsStore.draftPostTitle
                self.message = settingsStore.draftPostMessage
                self.attachments = []
                self.originalAttachmentIds = []
                self.isPollAdded = false
                self.pollQuestion = ""
                self.pollOptions = []
                
            case .edit(let post):
                self.postTopic = PostTopic(rawValue: post.data.topic ?? "") ?? .random
                self.title = post.data.title ?? ""
                self.message = post.data.content
                
                let existingAttachments = post.attachments.map { attachment in
                    UploadResponse(
                        id: attachment.id,
                        filename: attachment.filename,
                        url: attachment.url,
                        size: attachment.size,
                        isImage: attachment.isImage,
                        isVideo: attachment.isVideo,
                        isAudio: attachment.mimeType.hasPrefix("audio"),
                        mimeType: attachment.mimeType,
                    )
                }
                self.attachments = existingAttachments
                self.originalAttachmentIds = Set(existingAttachments.map(\.id))
                
                if let poll = post.poll {
                    self.isPollAdded = true
                    self.pollQuestion = poll.question
                    self.pollOptions = poll.options.map(\.label)
                } else {
                    self.isPollAdded = false
                    self.pollQuestion = ""
                    self.pollOptions = []
                }
            }
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
        
        func loadProjects() async {
            do {
                projects = try await api.profile(username: nil).projects
            } catch {
                dlog("Failed to load projects: \(error)")
            }
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
                
                switch mode {
                case .create:
                    try await api.createPost(
                        title: cleanTitle,
                        topic: postTopic,
                        content: message,
                        attachments: attachments,
                        pollQuestion: isPollAdded ? pollQuestion : nil,
                        pollOptions: isPollAdded ? pollOptions : [],
                        projectLink: selectedProjectId,
                    )
                    
                case .edit(let post):
                    guard let slug = post.data.slug else {
                        throw DevPlaceError.postNotEditable
                    }
                    try await api.editPost(
                        slug: slug,
                        title: cleanTitle ?? "",
                        topic: postTopic,
                        content: message,
                        attachments: attachments,
                        pollQuestion: isPollAdded ? pollQuestion : "",
                        pollOptions: isPollAdded ? pollOptions : [],
                        projectLink: selectedProjectId ?? "",
                    )
                }
                
                try? await AppState.shared.loadFeed(api: api)
                
                title = ""
                message = ""
                attachments = []
                isPollAdded = false
                pollQuestion = ""
                pollOptions = []
                selectedProjectId = nil
                
                dismiss.send()
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        func deleteUnsubmittedAttachments() async {
            let unsubmitted = attachments.filter { !originalAttachmentIds.contains($0.id) }
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
