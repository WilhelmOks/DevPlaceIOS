import Foundation
import DevPlaceSwiftSDK

protocol DevPlaceApi {
    func logIn(email: String, password: String) async throws
    func feed(before: Date?) async throws -> Feed
    func post(title: String?, topic: String?, content: String) async throws
    func profile(username: String?) async throws -> Profile
    func vote(targetType: TargetType, targetId: String, vote: Vote) async throws
    func submitPollChoice(pollId: String, optionId: String?) async throws
}

extension DevPlaceApi {
    func feed() async throws -> Feed {
        try await feed(before: nil)
    }
    
    private func logInWithStoredCredentials() async throws {
        let store = UserSessionStore.shared
        guard let email = store.email, let password = store.password else {
            return
        }
        try await logIn(email: email, password: password)
    }
    
    func refreshTokenIfNeeded() async throws {
        if let token = AppState.shared.token {
            if token.willExpireSoon {
                try await logInWithStoredCredentials()
                dlog("Refreshed token which was about to expire soon")
            }
        }
    }
}
