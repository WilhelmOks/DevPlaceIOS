import Foundation
import DevPlaceSwiftSDK

protocol DevPlaceApi {
    func logIn(email: String, password: String) async throws
    func feed() async throws -> Feed
    func post(title: String?, topic: String?, content: String) async throws
}
