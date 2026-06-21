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
    
    func feed() async throws -> Feed {
        try await refreshTokenIfNeeded()
        return try await request.getFeed(token: AppState.shared.token)
    }
    
    func post(title: String?, topic: String?, content: String) async throws {
        guard let token = AppState.shared.token else {
            throw DevPlaceError.notLoggedIn
        }
        try await refreshTokenIfNeeded()
        try await request.createPost(title: title, topic: topic, content: content, token: token)
    }
}
