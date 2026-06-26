import Foundation
import KreeRequest

public struct DevPlaceRequest: Sendable {
    let request: KreeRequest
    let backend = DevPlaceBackend()
    let ignoreCertificateErrors: Bool

    enum ContentTypeKind {
        case urlEncoded
        case jsonBody
    }

    public init(requestLogger: Logger, ignoreCertificateErrors: Bool = false) {
        self.ignoreCertificateErrors = ignoreCertificateErrors
        self.request = KreeRequest(encoder: .devPlace, decoder: .devPlace, logger: requestLogger)
    }

    private func makeConfig(
        _ method: KreeRequest.Method,
        path: String,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        contentType: ContentTypeKind = .urlEncoded,
        token: AuthToken? = nil
    ) -> KreeRequest.Config {
        var urlParameters = urlParameters

        var headers = headers

        if let token {
            headers["Authorization"] = "Bearer \(token.accessToken)"
        }

        headers["Accept"] = "application/json"

        switch contentType {
        case .urlEncoded:
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        case .jsonBody:
            headers["Content-Type"] = "application/json"
        }

        return .init(
            method: method,
            backend: backend,
            path: path,
            urlParameters: urlParameters,
            headers: headers,
            ignoreCertificateErrors: ignoreCertificateErrors
        )
    }
}

public extension DevPlaceRequest {
    private typealias ApiError = DevPlaceApiError.CodingData

    // MARK: - Auth

    func getAuthToken(email: String, password: String) async throws -> AuthToken {
        struct Body: Encodable {
            let email: String
            let password: String
        }

        let config = makeConfig(.post, path: "auth/token", contentType: .jsonBody)
        let body = Body(email: email, password: password)
        let response: AuthToken.CodingData = try await request.requestJson(config: config, json: body, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Feed

    func getFeed(
        tab: String? = nil,
        topic: String? = nil,
        search: String? = nil,
        before: Date? = nil,
        token: AuthToken?
    ) async throws -> Feed {
        var parameters: [String: String] = [:]
        if let tab { parameters["tab"] = tab }
        if let topic { parameters["topic"] = topic }
        if let search { parameters["search"] = search }
        if let before { parameters["before"] = before.formatted(.iso8601) }
        let config = makeConfig(.get, path: "feed", urlParameters: parameters, token: token)
        let response: Feed.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Posts

    func getPost(slug: String, token: AuthToken?) async throws -> PostDetail {
        let config = makeConfig(.get, path: "posts/\(slug)", token: token)
        let response: PostDetail.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func createPost(title: String?, topic: String?, content: String, token: AuthToken) async throws {
        struct Body: Encodable {
            let title: String?
            let topic: String?
            let content: String
        }

        let config = makeConfig(.post, path: "posts/create", contentType: .jsonBody, token: token)
        let body = Body(title: title, topic: topic, content: content)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func editPost(slug: String, title: String?, topic: String?, content: String, token: AuthToken) async throws {
        struct Body: Encodable {
            let title: String?
            let topic: String?
            let content: String
        }

        let config = makeConfig(.post, path: "posts/edit/\(slug)", contentType: .jsonBody, token: token)
        let body = Body(title: title, topic: topic, content: content)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func deletePost(slug: String, token: AuthToken) async throws {
        let config = makeConfig(.post, path: "posts/delete/\(slug)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    // MARK: - Comments

    func createComment(targetType: String, targetId: String, content: String, parentId: String?, token: AuthToken) async throws {
        struct Body: Encodable {
            let target_type: String
            let target_uid: String
            let content: String
            let parent_uid: String?
        }

        let config = makeConfig(.post, path: "comments/create", contentType: .jsonBody, token: token)
        let body = Body(target_type: targetType, target_uid: targetId, content: content, parent_uid: parentId)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func editComment(uid: String, content: String, token: AuthToken) async throws {
        struct Body: Encodable {
            let content: String
        }

        let config = makeConfig(.post, path: "comments/edit/\(uid)", contentType: .jsonBody, token: token)
        let body = Body(content: content)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func deleteComment(uid: String, token: AuthToken) async throws {
        let config = makeConfig(.post, path: "comments/delete/\(uid)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    // MARK: - Projects

    func getProjects(
        tab: String? = nil,
        search: String? = nil,
        projectType: String? = nil,
        before: Date? = nil,
        token: AuthToken?
    ) async throws -> Projects {
        var parameters: [String: String] = [:]
        if let tab { parameters["tab"] = tab }
        if let search { parameters["search"] = search }
        if let projectType { parameters["project_type"] = projectType }
        if let before { parameters["before"] = before.formatted(.iso8601) }
        let config = makeConfig(.get, path: "projects", urlParameters: parameters, token: token)
        let response: Projects.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func getProject(slug: String, token: AuthToken?) async throws -> ProjectDetail {
        let config = makeConfig(.get, path: "projects/\(slug)", token: token)
        let response: ProjectDetail.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Gists

    func getGists(
        language: String? = nil,
        userId: String? = nil,
        search: String? = nil,
        before: Date? = nil,
        token: AuthToken?
    ) async throws -> Gists {
        var parameters: [String: String] = [:]
        if let language { parameters["language"] = language }
        if let userId { parameters["user_uid"] = userId }
        if let search { parameters["search"] = search }
        if let before { parameters["before"] = before.formatted(.iso8601) }
        let config = makeConfig(.get, path: "gists", urlParameters: parameters, token: token)
        let response: Gists.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func getGist(slug: String, token: AuthToken?) async throws -> GistDetail {
        let config = makeConfig(.get, path: "gists/\(slug)", token: token)
        let response: GistDetail.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - News

    func getNews(before: Date? = nil, token: AuthToken?) async throws -> News {
        var parameters: [String: String] = [:]
        if let before { parameters["before"] = before.formatted(.iso8601) }
        let config = makeConfig(.get, path: "news", urlParameters: parameters, token: token)
        let response: News.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func getArticle(slug: String, token: AuthToken?) async throws -> ArticleDetail {
        let config = makeConfig(.get, path: "news/\(slug)", token: token)
        let response: ArticleDetail.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Profile

    func getProfile(username: String, tab: String? = nil, token: AuthToken?) async throws -> Profile {
        var parameters: [String: String] = [:]
        if let tab { parameters["tab"] = tab }
        let config = makeConfig(.get, path: "profile/\(username)", urlParameters: parameters, token: token)
        let response: Profile.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func searchProfiles(q: String, token: AuthToken) async throws -> UserSearch {
        let config = makeConfig(.get, path: "profile/search", urlParameters: ["q": q], token: token)
        let response: UserSearch.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Social Graph

    func getFollowers(username: String, page: Int? = nil, token: AuthToken?) async throws -> Followers {
        var parameters: [String: String] = [:]
        if let page { parameters["page"] = "\(page)" }
        let config = makeConfig(.get, path: "profile/\(username)/followers", urlParameters: parameters, token: token)
        let response: Followers.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func getFollowing(username: String, page: Int? = nil, token: AuthToken?) async throws -> Following {
        var parameters: [String: String] = [:]
        if let page { parameters["page"] = "\(page)" }
        let config = makeConfig(.get, path: "profile/\(username)/following", urlParameters: parameters, token: token)
        let response: Following.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func followUser(username: String, token: AuthToken) async throws {
        let config = makeConfig(.post, path: "follow/\(username)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    func unfollowUser(username: String, token: AuthToken) async throws {
        let config = makeConfig(.post, path: "follow/unfollow/\(username)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    // MARK: - Leaderboard

    func getLeaderboard(token: AuthToken?) async throws -> Leaderboard {
        let config = makeConfig(.get, path: "leaderboard", token: token)
        let response: Leaderboard.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Engagement

    func vote(targetType: String, targetId: String, value: Int, token: AuthToken) async throws {
        struct Body: Encodable {
            let value: Int
        }
        let config = makeConfig(.post, path: "votes/\(targetType)/\(targetId)", contentType: .jsonBody, token: token)
        let body = Body(value: value)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func react(targetType: String, targetId: String, emoji: String, token: AuthToken) async throws {
        struct Body: Encodable {
            let emoji: String
        }
        let config = makeConfig(.post, path: "reactions/\(targetType)/\(targetId)", contentType: .jsonBody, token: token)
        let body = Body(emoji: emoji)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func toggleBookmark(targetType: String, targetId: String, token: AuthToken) async throws {
        let config = makeConfig(.post, path: "bookmarks/\(targetType)/\(targetId)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    func getBookmarks(before: Date? = nil, token: AuthToken) async throws -> Bookmarks {
        var parameters: [String: String] = [:]
        if let before { parameters["before"] = before.formatted(.iso8601) }
        let config = makeConfig(.get, path: "bookmarks/saved", urlParameters: parameters, token: token)
        let response: Bookmarks.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Messaging

    func getMessages(withUid: String? = nil, search: String? = nil, token: AuthToken) async throws -> MessagesInbox {
        var parameters: [String: String] = [:]
        if let withUid { parameters["with_uid"] = withUid }
        if let search { parameters["search"] = search }
        let config = makeConfig(.get, path: "messages", urlParameters: parameters, token: token)
        let response: MessagesInbox.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func sendMessage(receiverId: String, content: String, token: AuthToken) async throws {
        struct Body: Encodable {
            let receiver_uid: String
            let content: String
        }
        let config = makeConfig(.post, path: "messages/send", contentType: .jsonBody, token: token)
        let body = Body(receiver_uid: receiverId, content: content)
        try await request.requestJson(config: config, json: body, apiError: ApiError.self)
    }

    func searchMessageRecipients(q: String, token: AuthToken) async throws -> UserSearch {
        let config = makeConfig(.get, path: "messages/search", urlParameters: ["q": q], token: token)
        let response: UserSearch.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    // MARK: - Notifications

    func getNotifications(before: Date? = nil, token: AuthToken) async throws -> Notifications {
        var parameters: [String: String] = [:]
        if let before { parameters["before"] = before.formatted(.iso8601) }
        let config = makeConfig(.get, path: "notifications", urlParameters: parameters, token: token)
        let response: Notifications.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
        return response.decoded
    }

    func markNotificationRead(uid: String, token: AuthToken) async throws {
        let config = makeConfig(.post, path: "notifications/mark-read/\(uid)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    func markAllNotificationsRead(token: AuthToken) async throws {
        let config = makeConfig(.post, path: "notifications/mark-all-read", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }

    // MARK: - Uploads

    func uploadFromUrl(url: String, filename: String? = nil, token: AuthToken) async throws -> UploadResponse {
        struct Body: Encodable {
            let url: String
            let filename: String?
        }
        let config = makeConfig(.post, path: "uploads/upload-url", contentType: .jsonBody, token: token)
        let body = Body(url: url, filename: filename)
        let response: UploadResponse.CodingData = try await request.requestJson(config: config, json: body, apiError: ApiError.self)
        return response.decoded
    }

    func deleteAttachment(uid: String, token: AuthToken) async throws {
        let config = makeConfig(.delete, path: "uploads/delete/\(uid)", token: token)
        try await request.requestJson(config: config, apiError: ApiError.self)
    }
}
