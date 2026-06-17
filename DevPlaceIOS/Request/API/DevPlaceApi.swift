import Foundation
import DevPlaceSwiftSDK

protocol DevPlaceApi {
    func feed() async throws -> Feed
}
