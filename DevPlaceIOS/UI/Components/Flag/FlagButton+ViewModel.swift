import Foundation
import Observation
import DevPlaceSwiftSDK

extension FlagButton {
    @Observable final class ViewModel {
        let targetType: TargetType
        let targetId: String
        let api: DevPlaceApi
        
        var alertMessage: AlertMessage = .none()
        var isLoading = false
        
        init(
            targetType: TargetType,
            targetId: String,
            api: DevPlaceApi,
        ) {
            self.targetType = targetType
            self.targetId = targetId
            self.api = api
        }
        
        var targetNoun: String {
            targetType == .comment ? "comment" : "post"
        }
        
        var confirmationTitle: String {
            targetType == .comment
                ? "Flag this comment for violating the Terms of Use?"
                : "Flag this post for violating the Terms of Use?"
        }
        
        func flag() async {
            guard !isLoading else { return }
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await api.flag(targetType: targetType, targetId: targetId)
                alertMessage = .presentedMessage("Thank you. This \(targetNoun) has been flagged.")
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
