public struct MessagesInbox: Hashable, Sendable {
    public let conversations: [Conversation]
    public let messages: [Message]
    public let otherUser: User
    public let currentConversation: String
    public let search: String
    public let otherOnline: Bool
    public let otherLastSeen: String

    public init(
        conversations: [Conversation],
        messages: [Message],
        otherUser: User,
        currentConversation: String,
        search: String,
        otherOnline: Bool,
        otherLastSeen: String,
    ) {
        self.conversations = conversations
        self.messages = messages
        self.otherUser = otherUser
        self.currentConversation = currentConversation
        self.search = search
        self.otherOnline = otherOnline
        self.otherLastSeen = otherLastSeen
    }
}

extension MessagesInbox {
    struct CodingData: Decodable {
        let conversations: [Conversation.CodingData]
        let messages: [Message.CodingData]
        let other_user: User.CodingData
        let current_conversation: String
        let search: String
        let other_online: Bool
        let other_last_seen: String
    }
}

extension MessagesInbox.CodingData {
    var decoded: MessagesInbox {
        .init(
            conversations: conversations.map(\.decoded),
            messages: messages.map(\.decoded),
            otherUser: other_user.decoded,
            currentConversation: current_conversation,
            search: search,
            otherOnline: other_online,
            otherLastSeen: other_last_seen,
        )
    }
}
