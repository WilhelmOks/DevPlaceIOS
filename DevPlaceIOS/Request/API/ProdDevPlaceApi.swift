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
        AppState.shared.currentUser = try? await request.getProfile(username: nil, token: token).user
    }
    
    func feed(before: Date?) async throws -> Feed {
        try await refreshTokenIfNeeded()
        return try await request.getFeed(before: before, token: AppState.shared.token)
    }
    
    func postDetail(slug: String) async throws -> PostDetail {
        try await refreshTokenIfNeeded()
        return try await request.getPost(slug: slug, token: AppState.shared.token)
    }
    
    func createPost(title: String?, topic: PostTopic?, content: String, attachments: [UploadResponse], pollQuestion: String?, pollOptions: [String], projectLink: String?) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.createPost(title: title, topic: topic, content: content, attachments: attachments, pollQuestion: pollQuestion, pollOptions: pollOptions, projectLink: projectLink, token: token)
    }
    
    func editPost(slug: String, title: String, topic: PostTopic, content: String, attachments: [UploadResponse], pollQuestion: String, pollOptions: [String], projectLink: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.editPost(slug: slug, title: title, topic: topic, content: content, attachments: attachments, pollQuestion: pollQuestion, pollOptions: pollOptions, projectLink: projectLink, token: token)
    }
    
    func deletePost(slug: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.deletePost(slug: slug, token: token)
    }
    
    func vote(targetType: TargetType, targetId: String, vote: Vote) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.vote(targetType: targetType, targetId: targetId, vote: vote, token: token)
    }
    
    func submitPollChoice(pollId: String, optionId: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.submitPollChoice(pollId: pollId, optionId: optionId, token: token)
    }
    
    func react(targetType: TargetType, targetId: String, emoji: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.react(targetType: targetType, targetId: targetId, emoji: emoji, token: token)
    }
    
    func uploadFile(data: Data, filename: String, mimeType: String) async throws -> UploadResponse {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        return try await request.uploadFile(data: data, filename: filename, mimeType: mimeType, token: token)
    }
    
    func uploadFromUrl(url: String, filename: String?) async throws -> UploadResponse {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        return try await request.uploadFromUrl(url: url, filename: filename, token: token)
    }
    
    func deleteAttachment(uid: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.deleteAttachment(uid: uid, token: token)
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
