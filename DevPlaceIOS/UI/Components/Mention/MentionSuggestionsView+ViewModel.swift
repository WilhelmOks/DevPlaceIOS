import Foundation
import Observation
import DevPlaceSwiftSDK

extension MentionSuggestionsView {
    @Observable final class ViewModel {
        let api: DevPlaceApi

        var isActive = false
        var suggestions: [UserSearch.Result] = []

        private var participants: [UserSearch.Result] = []
        private var activeQuery: String?
        private var searchTask: Task<Void, Never>?

        private let searchDebounce: Duration = .milliseconds(300)

        init(api: DevPlaceApi) {
            self.api = api
        }

        func update(text: String, caret: String.Index?, participants: [UserSearch.Result]) {
            self.participants = participants

            guard let token = MentionToken.active(in: text, caret: caret) else {
                deactivate()
                return
            }

            isActive = true

            if token.query.isEmpty {
                searchTask?.cancel()
                searchTask = nil
                activeQuery = nil
                suggestions = mentionable(participants)
            } else if token.query != activeQuery {
                activeQuery = token.query
                scheduleSearch(matching: token.query)
            }
        }

        func dismiss() {
            deactivate()
        }

        private func deactivate() {
            searchTask?.cancel()
            searchTask = nil
            activeQuery = nil
            isActive = false
            suggestions = []
        }

        private func scheduleSearch(matching query: String) {
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: searchDebounce)
                guard !Task.isCancelled else {
                    return
                }
                do {
                    let result = try await api.usersForMentioning(matching: query)
                    guard !Task.isCancelled else {
                        return
                    }
                    suggestions = mentionable(result.results)
                } catch {
                    guard !Task.isCancelled else {
                        return
                    }
                    dlog("Mention search failed for \"\(query)\": \(error)")
                }
            }
        }

        private func mentionable(_ users: [UserSearch.Result]) -> [UserSearch.Result] {
            users.filter { !AppState.shared.isCurrentUser(id: $0.id) }
        }
    }
}
