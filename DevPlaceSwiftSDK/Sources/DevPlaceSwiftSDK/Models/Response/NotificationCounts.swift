public struct NotificationCounts: Hashable, Sendable {
    public let notifications: Int
    public let messages: Int

    public init(
        notifications: Int,
        messages: Int,
    ) {
        self.notifications = notifications
        self.messages = messages
    }
}

extension NotificationCounts {
    struct CodingData: Decodable {
        let notifications: Int
        let messages: Int
    }
}

extension NotificationCounts.CodingData {
    var decoded: NotificationCounts {
        .init(
            notifications: notifications,
            messages: messages,
        )
    }
}
