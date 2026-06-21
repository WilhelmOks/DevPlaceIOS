import Foundation
import DevPlaceSwiftSDK
import Observation

@Observable
final class UserSessionStore {
    static let shared = UserSessionStore()
    
    var token: AuthToken?
}
