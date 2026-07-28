import Foundation
import Observation
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
        
        let titleLimit = 500
        let messageLimit = 125_000
        
        init(api: DevPlaceApi) {
            self.api = api
            self.title = settingsStore.draftPostTitle
            self.message = settingsStore.draftPostMessage
        }
        
        var canSubmit: Bool {
            let titleOk = TextCharacterCounter.numberOfCharacters(title) <= titleLimit
            let messageOk = TextCharacterCounter.numberOfCharacters(message) <= messageLimit && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return titleOk && messageOk
        }
    }
}
