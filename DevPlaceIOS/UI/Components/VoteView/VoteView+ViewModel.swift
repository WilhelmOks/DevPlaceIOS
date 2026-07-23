import Foundation
import Observation
import DevPlaceSwiftSDK

extension VoteView {
    @Observable final class ViewModel {
        let targetType: TargetType
        let targetId: String
        let api: DevPlaceApi
        
        var count: Int
        var currentVote: Vote
        
        var alertMessage: AlertMessage = .none()
        
        var isLoading = false
        
        var userCanVote: Bool {
            AppState.shared.isLoggedIn
        }
        
        init(
            targetType: TargetType,
            targetId: String,
            count: Int,
            vote: Vote,
            api: DevPlaceApi,
        ) {
            self.targetType = targetType
            self.targetId = targetId
            self.count = count
            self.currentVote = vote
            self.api = api
        }
        
        func tapUp() async {
            guard !isLoading else { return }
            let newVote: Vote = currentVote == .up ? .none : .up
            await apply(newVote: newVote)
        }
        
        func tapDown() async {
            guard !isLoading else { return }
            let newVote: Vote = currentVote == .down ? .none : .down
            await apply(newVote: newVote)
        }
        
        private func apply(newVote: Vote) async {
            isLoading = true
            defer { isLoading = false }
            
            let previousVote = currentVote
            let previousCount = count
            
            currentVote = newVote
            count = previousCount + newVote.value - previousVote.value
            
            do {
                try await api.vote(targetType: targetType, targetId: targetId, vote: newVote)
            } catch {
                currentVote = previousVote
                count = previousCount
                alertMessage = .presentedError(error)
            }
        }
    }
}
