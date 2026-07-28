import Foundation
import Observation
import DevPlaceSwiftSDK

extension CreatePostView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        var postTopic: PostTopic = .random
        var title = ""
        var message = ""
        
        let titleLimit = 500
        let messageLimit = 125_000
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        var canSubmit: Bool {
            let titleOk = TextCharacterCounter.numberOfCharacters(title) <= titleLimit
            let messageOk = TextCharacterCounter.numberOfCharacters(message) <= messageLimit && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return titleOk && messageOk
        }
    }
}
