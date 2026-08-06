import Foundation
import DevPlaceSwiftSDK

protocol MessagesSocket {
    var events: AsyncStream<ChatSocketEvent> { get }
    func connect() async
    func disconnect() async
    func send(content: String, attachmentUids: [String], clientId: String) async
    func sendTyping() async
    func sendRead(withUid uid: String) async
}
