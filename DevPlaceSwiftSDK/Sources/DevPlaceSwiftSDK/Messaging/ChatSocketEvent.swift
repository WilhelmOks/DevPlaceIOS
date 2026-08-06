import Foundation

public enum ChatSocketEvent: Sendable {
    case ready(userUid: String)
    case message(ChatSocketIncomingMessage)
    case typing(fromUid: String)
    case read(byUid: String)
    case failed(clientId: String?, text: String)
    case disconnected
}

public struct ChatSocketIncomingMessage: Sendable {
    public let uid: String
    public let senderUid: String
    public let receiverUid: String
    public let content: String
    public let createdAt: Date
    public let attachments: [Attachment]
    public let clientId: String?

    public init(
        uid: String,
        senderUid: String,
        receiverUid: String,
        content: String,
        createdAt: Date,
        attachments: [Attachment],
        clientId: String?,
    ) {
        self.uid = uid
        self.senderUid = senderUid
        self.receiverUid = receiverUid
        self.content = content
        self.createdAt = createdAt
        self.attachments = attachments
        self.clientId = clientId
    }
}
