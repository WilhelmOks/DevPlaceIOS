import Foundation
import DevPlaceSwiftSDK

protocol DevPlaceApi {
    func logIn(email: String, password: String) async throws
    func feed(before: Date?) async throws -> Feed
    func postDetail(slug: String) async throws -> PostDetail
    func createPost(title: String?, topic: PostTopic?, content: String, attachments: [UploadResponse], pollQuestion: String?, pollOptions: [String], projectLink: String?) async throws
    func editPost(slug: String, title: String, topic: PostTopic, content: String, projectLink: String) async throws
    func deletePost(slug: String) async throws
    func deleteComment(uid: String) async throws
    func editComment(uid: String, content: String) async throws
    func createComment(targetType: TargetType, targetId: String, content: String, parentId: String?, attachments: [UploadResponse]) async throws
    func profile(username: String?) async throws -> Profile
    func notifications(before: Date?) async throws -> Notifications
    func notificationCounts() async throws -> NotificationCounts
    func markNotificationRead(uid: String) async throws
    func markAllNotificationsRead() async throws
    func vote(targetType: TargetType, targetId: String, vote: Vote) async throws
    func submitPollChoice(pollId: String, optionId: String) async throws
    func react(targetType: TargetType, targetId: String, emoji: String) async throws
    func uploadFile(data: Data, filename: String, mimeType: String) async throws -> UploadResponse
    func uploadFromUrl(url: String, filename: String?) async throws -> UploadResponse
    func deleteAttachment(uid: String) async throws
}

extension DevPlaceApi {
    func feed() async throws -> Feed {
        try await feed(before: nil)
    }

    func notifications() async throws -> Notifications {
        try await notifications(before: nil)
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
