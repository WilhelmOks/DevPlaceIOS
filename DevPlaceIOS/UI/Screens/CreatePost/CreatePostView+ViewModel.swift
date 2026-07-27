import Foundation
import Observation
import DevPlaceSwiftSDK

extension CreatePostView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        var postTopic: PostTopic = .random
        
        init(api: DevPlaceApi) {
            self.api = api
        }
    }
}
