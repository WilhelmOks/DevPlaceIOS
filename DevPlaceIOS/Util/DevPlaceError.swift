import Foundation

enum DevPlaceError: Error {
    case invalidUrl(_ string: String)
    
    var message: String {
        switch self {
        case .invalidUrl(let string):
            return "Invalid URL: \(string)"
        }
    }
}
