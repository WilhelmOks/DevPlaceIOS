import Foundation
import DevPlaceSwiftSDK

extension DevPlaceApi where Self == MockDevPlaceApi {
    static var mock: Self {
        .shared
    }
}

final class MockDevPlaceApi: DevPlaceApi {
    static let shared = MockDevPlaceApi()
    
    private func mockDelay(_ delay: TimeInterval = 1) async {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    func logIn(email: String, password: String) async throws {
        await mockDelay()
        let token = AuthToken(
            tokenType: "bearer",
            accessToken: UUID().uuidString,
            expireTime: Date().addingTimeInterval(60 * 60 + 10)
        )
        AppState.shared.token = token
        AppState.shared.currentUser = Profile.mock.user
    }
    
    func feed(before: Date?) async throws -> Feed {
        await mockDelay()
        try await refreshTokenIfNeeded()
        return .mock
    }
    
    func postDetail(slug: String) async throws -> PostDetail {
        await mockDelay()
        try await refreshTokenIfNeeded()
        return .mock
    }
    
    func createPost(title: String?, topic: PostTopic?, content: String, attachments: [UploadResponse], pollQuestion: String?, pollOptions: [String], projectLink: String?) async throws {
        await mockDelay()
        try await refreshTokenIfNeeded()
    }
    
    func deletePost(slug: String) async throws {
        await mockDelay(0.2)
        try await refreshTokenIfNeeded()
    }
    
    func profile(username: String?) async throws -> Profile {
        await mockDelay(0.1)
        try await refreshTokenIfNeeded()
        return .mock
    }
    
    func vote(targetType: TargetType, targetId: String, vote: Vote) async throws {
        await mockDelay(0.2)
        try await refreshTokenIfNeeded()
    }
    
    func submitPollChoice(pollId: String, optionId: String) async throws {
        await mockDelay(0.2)
        try await refreshTokenIfNeeded()
    }
    
    func react(targetType: TargetType, targetId: String, emoji: String) async throws {
        await mockDelay(0.2)
        try await refreshTokenIfNeeded()
    }
    
    func uploadFile(data: Data, filename: String, mimeType: String) async throws -> UploadResponse {
        await mockDelay()
        try await refreshTokenIfNeeded()
        return UploadResponse(
            id: UUID().uuidString,
            filename: filename,
            url: "https://example.com/\(filename)",
            size: data.count,
            isImage: mimeType.hasPrefix("image"),
            isVideo: mimeType.hasPrefix("video"),
            isAudio: mimeType.hasPrefix("audio"),
            mimeType: mimeType,
        )
    }
    
    func uploadFromUrl(url: String, filename: String?) async throws -> UploadResponse {
        await mockDelay()
        try await refreshTokenIfNeeded()
        let resolvedFilename = filename ?? (URL(string: url)?.lastPathComponent ?? "attachment")
        return UploadResponse(
            id: UUID().uuidString,
            filename: resolvedFilename,
            url: url,
            size: 0,
            isImage: false,
            isVideo: false,
            isAudio: false,
            mimeType: "application/octet-stream",
        )
    }
    
    func deleteAttachment(uid: String) async throws {
        await mockDelay(0.2)
        try await refreshTokenIfNeeded()
    }
}
