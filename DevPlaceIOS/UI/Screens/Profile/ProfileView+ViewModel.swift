import Foundation
import Observation
import DevPlaceSwiftSDK

extension ProfileView {
    @Observable final class ViewModel {
        let username: String?
        
        let api: DevPlaceApi
        
        var isLoading = false
        
        var alertMessage: AlertMessage = .none()
        
        var profile: Profile?
        
        init(username: String?, api: DevPlaceApi) {
            self.username = username
            self.api = api
        }
        
        func load() async {
            isLoading = true
            defer { isLoading = false }
            
            do {
                profile = try await api.profile(username: username)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
