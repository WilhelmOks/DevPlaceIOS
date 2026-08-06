import Foundation
import DevPlaceSwiftSDK

enum ChatSocketEvent {
    case ready(userUid: String)
    case message(ChatSocketIncomingMessage)
    case typing(fromUid: String)
    case read(byUid: String)
    case failed(clientId: String?, text: String)
    case disconnected
}

struct ChatSocketIncomingMessage {
    let uid: String
    let senderUid: String
    let receiverUid: String
    let content: String
    let createdAt: Date
    let attachments: [Attachment]
    let clientId: String?
}

protocol MessagesSocket {
    var events: AsyncStream<ChatSocketEvent> { get }
    func connect() async
    func disconnect() async
    func send(content: String, attachmentUids: [String], clientId: String) async
    func sendTyping() async
    func sendRead(withUid uid: String) async
}
