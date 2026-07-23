import Foundation
import Observation
import DevPlaceSwiftSDK

extension PollView {
    @Observable final class ViewModel {
        let pollId: String
        let question: String
        let api: DevPlaceApi
        
        var options: [PollOption]
        var total: Int
        var myChoice: String?
        
        var alertMessage: AlertMessage = .none()
        
        var isLoading = false
        
        var userCanVote: Bool {
            AppState.shared.isLoggedIn
        }
        
        init(poll: Poll, api: DevPlaceApi) {
            self.pollId = poll.id
            self.question = poll.question
            self.api = api
            self.options = poll.options
            self.total = poll.total
            self.myChoice = poll.myChoice
        }
        
        func tap(optionId: String) async {
            guard !isLoading, userCanVote else { return }
            let newChoice: String? = myChoice == optionId ? nil : optionId
            await apply(newChoice: newChoice)
        }
        
        private func apply(newChoice: String?) async {
            isLoading = true
            defer { isLoading = false }
            
            let previousChoice = myChoice
            let previousOptions = options
            let previousTotal = total
            
            let updated = recomputed(
                options: options,
                total: total,
                previousChoice: previousChoice,
                newChoice: newChoice,
            )
            options = updated.options
            total = updated.total
            myChoice = newChoice
            
            do {
                try await api.submitPollChoice(pollId: pollId, optionId: newChoice)
            } catch {
                options = previousOptions
                total = previousTotal
                myChoice = previousChoice
                alertMessage = .presentedError(error)
            }
        }
        
        private func recomputed(
            options: [PollOption],
            total: Int,
            previousChoice: String?,
            newChoice: String?,
        ) -> (options: [PollOption], total: Int) {
            var newTotal = total
            if previousChoice == nil, newChoice != nil {
                newTotal += 1
            } else if previousChoice != nil, newChoice == nil {
                newTotal -= 1
            }
            let newOptions = options.map { option -> PollOption in
                var count = option.count
                if option.id == previousChoice { count -= 1 }
                if option.id == newChoice { count += 1 }
                let pct = newTotal > 0 ? Int((Double(count) / Double(newTotal) * 100.0).rounded()) : 0
                return PollOption(
                    id: option.id,
                    label: option.label,
                    count: count,
                    votes: option.votes,
                    pct: pct,
                )
            }
            return (newOptions, newTotal)
        }
    }
}
