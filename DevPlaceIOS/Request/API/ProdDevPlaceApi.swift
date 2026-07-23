import Foundation
import DevPlaceSwiftSDK

extension DevPlaceApi where Self == ProdDevPlaceApi {
    static var prod: Self {
        .shared
    }
}

final class ProdDevPlaceApi: DevPlaceApi {
    static let shared = ProdDevPlaceApi()
    
    let logger = DevPlaceRequestLogger()
    let request: DevPlaceRequest
    
    init() {
        request = DevPlaceRequest(requestLogger: logger)
    }
    
    func logIn(email: String, password: String) async throws {
        let token = try await request.getAuthToken(email: email, password: password)
        AppState.shared.token = token
    }
    
    func feed(before: Date?) async throws -> Feed {
        try await refreshTokenIfNeeded()
        return try await request.getFeed(before: before, token: AppState.shared.token)
    }
    
    func post(title: String?, topic: String?, content: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.createPost(title: title, topic: topic, content: content, token: token)
    }
    
    func vote(targetType: TargetType, targetId: String, vote: Vote) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.vote(targetType: targetType, targetId: targetId, vote: vote, token: token)
    }
    
    func submitPollChoice(pollId: String, optionId: String?) async throws {
        // TODO: call request.submitPollChoice(pollId:optionId:token:) once DevPlaceSwiftSDK exposes it
        try await refreshTokenIfNeeded()
    }
    
    func profile(username: String?) async throws -> Profile {
        try await refreshTokenIfNeeded()
        if let username {
            // Fetching user profiles of other users should be fine without a token.
            return try await request.getProfile(username: username, token: AppState.shared.token)
        } else {
            // Fetching own profile requires a token.
            guard let token = AppState.shared.token else {
                throw DevPlaceError.notLoggedIn
            }
            return try await request.getProfile(username: username, token: token)
        }
    }
}
