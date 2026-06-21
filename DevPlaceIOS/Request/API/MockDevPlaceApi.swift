import Foundation
import DevPlaceSwiftSDK

extension DevPlaceApi where Self == MockDevPlaceApi {
    static var mock: Self {
        .shared
    }
}

final class MockDevPlaceApi: DevPlaceApi {
    static let shared = MockDevPlaceApi()
    
    func logIn(email: String, password: String) async throws {
        let token = AuthToken(
            tokenType: "bearer",
            accessToken: UUID().uuidString,
            expireTime: Date().addingTimeInterval(60 * 60 + 10)
        )
        UserSessionStore.shared.token = token
    }
    
    func feed() async throws -> Feed {
        .mock
    }
    
    func post(title: String?, topic: String?, content: String) async throws {
        
    }
}
