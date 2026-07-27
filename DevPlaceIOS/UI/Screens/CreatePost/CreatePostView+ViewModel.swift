import Foundation
import Observation
import DevPlaceSwiftSDK

extension CreatePostView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        var postTopic: PostTopic = .random
        var title = ""
        
        let titleLimit = 500
        
        init(api: DevPlaceApi) {
            self.api = api
        }
        
        var canSubmit: Bool {
            let titleOk = TextCharacterCounter.numberOfCharacters(title) <= titleLimit
            return titleOk
        }
    }
}
