import Foundation
import DevPlaceSwiftSDK

enum NotificationRoute {
    case post(PostDestination)
    case conversation(User)
    case web(URL)
    case ownProfile
}
