import Foundation
import DevPlaceSwiftSDK

protocol DevPlaceApi {
    func logIn(email: String, password: String) async throws
    func feed() async throws -> Feed
    func post(title: String?, topic: String?, content: String) async throws
    func profile(username: String?) async throws -> Profile
    func vote(targetType: TargetType, targetId: String, vote: Vote) async throws
}

extension DevPlaceApi {
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
