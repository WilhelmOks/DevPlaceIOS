import Foundation
import DevPlaceSwiftSDK

extension DevPlaceApi where Self == MockDevPlaceApi {
    static var mock: Self {
        .shared
    }
}

class MockDevPlaceApi: DevPlaceApi {
    static let shared = MockDevPlaceApi()
    
    func feed() async throws -> Feed {
        .mock
    }
}
