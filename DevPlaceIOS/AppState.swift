import Foundation
import Observation
import DevPlaceSwiftSDK

@Observable
final class AppState {
    static let shared = AppState()
    
    private init() {}
    
    var token: AuthToken?
    
    var isLoggedIn: Bool { token != nil }
    
    var feed: Feed?
    
    func clear() {
        feed = nil
    }
}
