import Foundation
import Observation
import Combine

extension TemplateView {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            self.api = api
        }
    }
}
