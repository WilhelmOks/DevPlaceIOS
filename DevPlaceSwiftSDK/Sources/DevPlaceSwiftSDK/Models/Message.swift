import Foundation

public struct Message: Hashable, Sendable, Identifiable {
    public var id: String { "message:" + data.id }
    public let data: Data
    public let sender: User
    public let isMine: Bool
    //public let timeAgo: String // exists in API; format on demand from data.createdAt
    public let attachments: [Attachment]

    public init(
        data: Data,
        sender: User,
        isMine: Bool,
        attachments: [Attachment],
    ) {
        self.data = data
        self.sender = sender
        self.isMine = isMine
        self.attachments = attachments
    }
}

public extension Message {
    struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let senderId: String
        public let receiverId: String
        public let content: String
        public let read: Bool
        public let createdAt: Date

        public init(
            id: String,
            senderId: String,
            receiverId: String,
            content: String,
            read: Bool,
            createdAt: Date,
        ) {
            self.id = id
            self.senderId = senderId
            self.receiverId = receiverId
            self.content = content
            self.read = read
            self.createdAt = createdAt
        }
    }
}

extension Message {
    struct CodingData: Decodable {
        let message: Data.CodingData
        let sender: User.CodingData
        let is_mine: Bool
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let attachments: [Attachment.CodingData]
    }
}

extension Message.Data {
    struct CodingData: Decodable {
        let uid: String
        let sender_uid: String
        let receiver_uid: String
        let content: String
        let read: Bool
        let created_at: Date
    }
}

extension Message.CodingData {
    var decoded: Message {
        .init(
            data: message.decoded,
            sender: sender.decoded,
            isMine: is_mine,
            attachments: attachments.map(\.decoded),
        )
    }
}

extension Message.Data.CodingData {
    var decoded: Message.Data {
        .init(
            id: uid,
            senderId: sender_uid,
            receiverId: receiver_uid,
            content: content,
            read: read,
            createdAt: created_at,
        )
    }
}
