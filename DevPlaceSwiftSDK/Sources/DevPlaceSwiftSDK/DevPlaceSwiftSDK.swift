import Foundation
import KreeRequest

public struct DevPlaceRequest: Sendable {
    let request: KreeRequest
    let backend = DevPlaceBackend()
    let ignoreCertificateErrors: Bool
    
    public init(requestLogger: Logger, ignoreCertificateErrors: Bool = false) {
        self.ignoreCertificateErrors = ignoreCertificateErrors
        self.request = KreeRequest(encoder: .devPlace, decoder: .devPlace, logger: requestLogger)
    }
    
    private func makeConfig(_ method: KreeRequest.Method, path: String, urlParameters: [String: String] = [:], headers: [String: String] = [:], token: AuthToken? = nil) -> KreeRequest.Config {
        var urlParameters = urlParameters
        
        if let token {
            urlParameters["token_id"] = String(token.id)
            urlParameters["token_key"] = token.key
            urlParameters["user_id"] = String(token.userId)
        }
        
        var headers = headers
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        
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
    func getFeed(token: AuthToken?) async throws -> Feed {
        var parameters: [String: String] = [:]
        
        let config = makeConfig(.get, path: "feed", urlParameters: parameters, token: token)
        
        let response: Feed.CodingData = try await request.requestJson(config: config, apiError: DevPlaceApiError.CodingData.self)
        
        return response.decoded
    }
}
