import Foundation
import DevPlaceSwiftSDK

extension DevPlaceApi where Self == MockDevPlaceApi {
    static var mock: Self {
        .shared
    }
}

final class MockDevPlaceApi: DevPlaceApi {
    static let shared = MockDevPlaceApi()
    
    private func mockDelay(delay: TimeInterval = 1) async {
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
    }
    
    func feed() async throws -> Feed {
        await mockDelay()
        try await refreshTokenIfNeeded()
        return .mock
    }
    
    func post(title: String?, topic: String?, content: String) async throws {
        await mockDelay()
        try await refreshTokenIfNeeded()
    }
    
    func profile(username: String?) async throws -> Profile {
        await mockDelay()
        try await refreshTokenIfNeeded()
        return .mock
    }
}
