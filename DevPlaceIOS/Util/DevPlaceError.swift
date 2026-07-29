import Foundation

enum DevPlaceError: Error {
    case notLoggedIn
    case invalidUrl(_ string: String)
    case postNotEditable
    
    var message: String {
        switch self {
        case .notLoggedIn:
            return "Not logged in"
        case .invalidUrl(let string):
            return "Invalid URL: \(string)"
        case .postNotEditable:
            return "This post cannot be edited"
        }
    }
}
