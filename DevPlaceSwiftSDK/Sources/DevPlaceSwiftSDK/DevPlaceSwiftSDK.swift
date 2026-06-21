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
    
    func getFeed(token: AuthToken?) async throws -> Feed {
        var parameters: [String: String] = [:]
        let config = makeConfig(.get, path: "feed", urlParameters: parameters, token: token)
        let response: Feed.CodingData = try await request.requestJson(config: config, apiError: ApiError.self)
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
}
