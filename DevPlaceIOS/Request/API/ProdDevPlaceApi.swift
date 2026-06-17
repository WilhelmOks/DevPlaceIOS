import Foundation
import DevPlaceSwiftSDK

extension DevPlaceApi where Self == ProdDevPlaceApi {
    static var prod: Self {
        .shared
    }
}

class ProdDevPlaceApi: DevPlaceApi {
    static let shared = ProdDevPlaceApi()
    
    let logger = DevPlaceRequestLogger()
    let request: DevPlaceRequest
    
    init() {
        request = DevPlaceRequest(requestLogger: logger)
    }
    
    func feed() async throws -> Feed {
        try await request.getFeed(token: nil)
    }
}
