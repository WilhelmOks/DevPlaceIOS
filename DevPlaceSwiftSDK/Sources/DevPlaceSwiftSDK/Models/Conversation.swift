public struct Conversation: Hashable, Sendable {
    public let otherUser: User
    public let lastMessage: String
    public let lastMessageAt: String
    public let unread: Bool

    public init(
        otherUser: User,
        lastMessage: String,
        lastMessageAt: String,
        unread: Bool,
    ) {
        self.otherUser = otherUser
        self.lastMessage = lastMessage
        self.lastMessageAt = lastMessageAt
        self.unread = unread
    }
}

extension Conversation {
    struct CodingData: Decodable {
        let other_user: User.CodingData
        let last_message: String
        let last_message_at: String
        let unread: Bool
    }
}

extension Conversation.CodingData {
    var decoded: Conversation {
        .init(
            otherUser: other_user.decoded,
            lastMessage: last_message,
            lastMessageAt: last_message_at,
            unread: unread,
        )
    }
}
